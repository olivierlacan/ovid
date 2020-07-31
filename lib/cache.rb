module Cache
  def self.cache
    Config.redis_pool
  end

  def self.check_cache(key)
    payload = cache.with { _1.get(key) }

    if payload
      puts "cache hit for #{key}"
      JSON.parse(payload, symbolize_names: true)
    else
      puts "cache miss for #{key}"
    end
  end

  def self.write_cache(key, value)
    puts "cache write for #{key}"
    payload = value.to_json

    cache.with do
      _1.multi do
        cache.with { |c| c.set(key, payload) }
        cache.with { |c| c.get(key) }
      end
    end
  end

  def self.set_expiration(key, time)
    cache.with { _1.expireat(key, time.to_i) }
  end

  def self.save_in_cache(cache_key, data, expiration_time = Time.now)
    write_cache(cache_key, data)
    set_expiration(cache_key, Time.now + (CACHE_EXPIRATION_IN_MINUTES * 60))
    check_cache(cache_key)
  end
end
