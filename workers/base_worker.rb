require "./lib/request"
require "./lib/cache"
require "./workers/base_worker"

class BaseWorker
  include Cache

  CACHE_EXPIRATION_IN_MINUTES = 60

  def get_last_edit(metadata)
    raw_edit_date = metadata[:editingInfo][:lastEditDate]
    converted_edit_date = Time.strptime(raw_edit_date.to_s, "%Q")
    puts "Parsed lastEditDate #{raw_edit_date} converted to #{converted_edit_date} (#{ENV["TZ"]})"

    converted_edit_date
  end

  def total_records_from_feature(url, query)
    Request.get("#{url}/query", params: query.merge({ returnCountOnly: true }))[:count]
  end

  def fields_from_feature(url)
    Request.get(url)[:fields].map { _1[:name] }
  end

  def save_in_cache(cache_key, data, expiration_time = Time.now)
    write_cache(cache_key, data)
    set_expiration(cache_key, Time.now + (CACHE_EXPIRATION_IN_MINUTES * 60))
    check_cache(cache_key)
  end

  def write_cache(key, value)
    puts "cache write for #{key}"
    payload = value.to_json
    puts "caching serialized payload: #{payload.inspect}"

    self.class.cache.with do
      _1.multi do
        self.class.cache.with { |c| c.set(key, payload) }
        self.class.cache.with { |c| c.get(key) }
      end
    end
  end

  def check_cache(key)
    payload = self.class.cache.with { _1.get(key) }

    if payload
      puts "cache hit for #{key}"
      JSON.parse(payload, symbolize_names: true)
    else
      puts "cache miss for #{key}"
    end
  end

  def set_expiration(key, time)
    self.class.cache.with { _1.expireat(key, time.to_i) }
  end

  def self.cache
    Config.redis_pool
  end

  def initialize_store(key_defaults)
    key_defaults.each_with_object({}) do |(key, metric), store|
      store[key] = {
        value: 0,
        name: metric[:name],
        description: metric[:description],
        highlight: metric[:highlight],
        source: metric[:source]
      }
    end
  end
end
