require "date"
require "time"
require "net/http"
require "json"

class State
  CACHE_EXPIRATION_IN_MINUTES = 15
  @@state_classes = []

  def self.inherited(instance)
    @@state_classes << instance
  end

  def self.all_states
    @@state_classes
  end

  def self.state_name
    self.to_s
  end

  def self.cache_key
    "covid_#{state_name.downcase}"
  end

  def self.testing_gallery_url
    raise NotImplementedError
  end

  def self.testing_feature_url
    "https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/arcgis/rest/services/Florida_Testing/FeatureServer/0?f=pjson"
  end

  def self.testing_data_url
    "https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/arcgis/rest/services/Florida_Testing/FeatureServer/0/query?where=1%3D1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=false&returnCentroid=false&featureEncoding=esriDefault&multipatchOption=none&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pjson"
  end

  def self.dashboard_url
    "https://experience.arcgis.com/experience/96dd742462124fa0b38ddedb9b25e429"
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

  def self.get_data
    uri = URI(testing_data_url)
    response = Net::HTTP.get(uri)
    parsed_response = JSON.parse(response)

    report = generate_report(parsed_response["features"])

    # set expiration time to 15 minutes from now
    last_fetch = Time.now
    expiration_time = last_fetch + (CACHE_EXPIRATION_IN_MINUTES * 60)

    cache = {
      last_edited_at: last_edit.iso8601,
      last_fetched_at: last_fetch.iso8601,
      expires_at: expiration_time.iso8601,
      data: report
    }

    write_cache(cache_key, cache)
    set_expiration(cache_key, expiration_time)
    check_cache(cache_key)
  end


  def self.generate_report(testing_data)
    testing_totals = relevant_keys.each_with_object({}) do |(key, metric), store|
      store[key] = {
        value: 0,
        name: metric[:name],
        description: metric[:description],
        highlight: metric[:highlight],
        source: metric[:source]
      }
    end

    testing_data.each_with_object(testing_totals) do |test, store|
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
end
