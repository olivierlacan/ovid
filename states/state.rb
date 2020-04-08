require "date"
require "time"
require "net/http"
require "json"

class State
  include Comparable

  CACHE_EXPIRATION_IN_MINUTES = 15
  @@state_classes = []

  def self.inherited(instance)
    @@state_classes << instance
  end

  def self.all_states
    @@state_classes.sort
  end

  def self.state_name
    self.deconstantize
  end

  def self.cache_key
    "covid_#{state_name.downcase}"
  end

  def self.testing_gallery_url
    nil
  end

  def self.testing_feature_url
    nil
  end

  def self.testing_data_url
    nil
  end

  def self.dashboard_url
    nil
  end

  def self.aggregate_feature_url
    nil
  end

  def self.aggregate_data_url
    nil
  end

   def self.covid_tracking_report(query_string)
    stored_response = check_cache(cache_key)

    if stored_response && !query_string.include?("reload")
      puts "Using stored_response..."
      stored_response
    else
      puts "Generating new report ..."
      get_data
    end
  end

  def self.last_edit
    puts "Fetching lastEditDate from feature layer #{testing_feature_url} ..."
    uri = URI(testing_feature_url)
    response = Net::HTTP.get(uri)
    parsed_response = JSON.parse(response)
    puts parsed_response.inspect
    raw_edit_date = parsed_response["editingInfo"]["lastEditDate"]
    converted_edit_date = Time.strptime(raw_edit_date.to_s, "%Q")
    puts "Parsed lastEditDate #{raw_edit_date} converted to #{converted_edit_date} (#{ENV["TZ"]})"

    converted_edit_date
  end

  def self.request(url)
    uri = URI(url)
    response = Net::HTTP.get(uri)

    JSON.parse(response)
  end

  def self.get_data
    if defined?(relevant_keys)
      relevant_response = request(testing_data_url)
      relevant_report = generate_roll_up_report(relevant_response["features"])
    end

    if defined?(aggregate_keys)
      aggregate_response = request(aggregate_data_url)
      aggregate_report = generate_aggregate_report(aggregate_response["features"])
    end

    # set expiration time to 15 minutes from now
    last_fetch = Time.now
    expiration_time = last_fetch + (CACHE_EXPIRATION_IN_MINUTES * 60)

    if defined?(aggregate_report) && !aggregate_report.nil?
      merged_data = relevant_report.merge(aggregate_report)
    else
      merged_data = relevant_report
    end

    cache = {
      last_edited_at: last_edit.iso8601,
      last_fetched_at: last_fetch.iso8601,
      expires_at: expiration_time.iso8601,
      data: merged_data
    }

    write_cache(cache_key, cache)
    set_expiration(cache_key, expiration_time)
    check_cache(cache_key)
  end

  def self.generate_roll_up_report(data)
    testing_store = initialize_store(relevant_keys)
    data.each_with_object(testing_store) do |test, store|
      a = test["attributes"]

      relevant_keys.each do |key, value|
        if value[:total]
          store[key][:value] = a[value[:source]]
        else
          store[key][:value] += a[value[:source]] || 0
        end
      end
    end
  end

  def self.generate_aggregate_report(data)
    aggregate_store = initialize_store(aggregate_keys)

    data.each_with_object(aggregate_store) do |data, store|
      a = data["attributes"]

      aggregate_keys.each do |key, value|
        store[key][:value] = a[value[:source]] || "N/A"
      end
    end
  end

  def self.initialize_store(key_defaults)
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

  def self.relevant_keys
    raise NotImplementedError
  end

  def self.production?
    ENV["RACK_ENV"] == "production"
  end

  def self.development?
    !production?
  end

  def self.cache
    @redis ||= if production?
      Redis.new(url: ENV["REDIS_URL"])
    else
      Redis.new
    end
  end

  def self.check_cache(key)
    payload = cache.get(key)

    if payload
      puts "cache hit for #{key}"
      JSON.parse(payload, { symbolize_names: true })
    else
      puts "cache miss for #{key}"
    end
  end

  def self.write_cache(key, value)
    puts "cache write for #{key}"
    payload = value.to_json
    puts "caching serialized payload: #{payload.inspect}"

    cache.multi do
      cache.set(key, payload)
      cache.get(key)
    end
  end

  def self.set_expiration(key, time)
    cache.expireat(key, time.to_i)
  end

  def self.deconstantize
    to_s.gsub(/([a-z])([A-Z])/, '\1 \2')
  end

  def self.parameterize
    to_s.gsub(/([a-z])([A-Z])/, '\1-\2').downcase
  end

  def self.<=>(other)
    to_s <=> other.to_s
  end
end
