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

  def self.counties_feature_url
    nil
  end

  def self.cases_feature_url
    nil
  end

  def self.aggregates_feature_url
    nil
  end

  def self.dashboard_url
    nil
  end

  def self.county_keys
    nil
  end

  def self.case_keys
    nil
  end

  def self.totals_keys
    nil
  end

  def self.county_cache_key
    "#{cache_key}-county-report"
  end

  def self.case_cache_key
    "#{cache_key}-case-report"
  end

  def self.totals_cache_key
    "#{cache_key}-totals-report"
  end

  def self.county_report(query_string)
    stored_response = check_cache(county_cache_key)

    if stored_response && !query_string.include?("reload")
      puts "Using stored_response..."
      stored_response
    else
      puts "Generating new report ..."
      get_county_data
    end
  end

  def self.case_report(query_string)
    stored_response = check_cache(case_cache_key)

    if stored_response && !query_string.include?("reload")
      puts "Using stored_response..."
      stored_response
    else
      puts "Generating new report ..."
      get_case_data
    end
  end

  def self.totals_report(query_string)
    stored_response = check_cache(totals_cache_key)

    if stored_response && !query_string.include?("reload")
      puts "Using stored_response..."
      stored_response
    else
      puts "Generating new report ..."
      get_totals_data
    end
  end

  def self.get(url, params = {})
    params = params.merge({ f: "pjson" })
    uri = URI(url)
    uri.query = URI.encode_www_form(params)
    puts "Sending GET request to #{uri} ..."
    response = Net::HTTP.get_response(uri)
    if response.is_a?(Net::HTTPSuccess)
      puts "Success!"
      JSON.parse(response.body)
    else
      raise "#{response.code}: #{response.message}"
      puts "Headers: #{res.to_hash.inspect}"
      puts res.body if response.response_body_permitted?
    end
  end

  def self.last_edit(metadata)
    raw_edit_date = metadata["editingInfo"]["lastEditDate"]
    converted_edit_date = Time.strptime(raw_edit_date.to_s, "%Q")
    puts "Parsed lastEditDate #{raw_edit_date} converted to #{converted_edit_date} (#{ENV["TZ"]})"

    converted_edit_date
  end

  def self.get_totals_data
    if totals_keys
      metadata = get(totals_feature_url)
      last_edit = last_edit(metadata)

      query = {
        where: "1=1",
        returnGeometry: false,
        outFields: "*",
        resultType: "standard"
      }

      response = get("#{totals_feature_url}/query", query)

      totals_report = generate_totals_report(
        response["features"],
        initialize_store(totals_keys)
      )
    end

    merged_data = {
      edited_at: last_edit,
      fetched_at: Time.now,
      data: totals_report
    }

    save_in_cache totals_cache_key, merged_data
  end

  def self.get_county_data
    if county_keys
      metadata = get(counties_feature_url)
      last_edit = last_edit(metadata)

      query = {
        where: "1=1",
        returnGeometry: false,
        outFields: "*",
        resultType: "standard"
      }

      response = get("#{counties_feature_url}/query", query)

      county_deaths_report = generate_deaths_by_county_report(
        response["features"]
      )
      county_report = generate_county_report(
        response["features"],
        initialize_store(county_keys)
      )
    end

    merged_data = {
      edited_at: last_edit,
      fetched_at: Time.now,
      data: county_report,
      death_data: county_deaths_report
    }

    save_in_cache county_cache_key, merged_data
  end

  def self.total_records_from_feature(url, query)
    get("#{url}/query", query.merge({ returnCountOnly: true }))["count"]
  end

  def self.get_case_data
    if cases_feature_url
      metadata = get(cases_feature_url)
      last_edit = last_edit(metadata)

      maximum_record_count = metadata["standardMaxRecordCount"]

      query = {
        where: "1=1",
        returnGeometry: false,
        outFields: "*",
        resultRecordCount: maximum_record_count,
        resultType: "standard"
      }

      record_total = total_records_from_feature(cases_feature_url, query)
      puts "Total records: #{record_total}"

      initial_response = get("#{cases_feature_url}/query", query)
      puts "Records in initial response: #{initial_response["features"].count}"

      last_item_id = initial_response["features"].last["attributes"]["ObjectId"]

      @response_data = []
      @response_data.push(*initial_response["features"])

      # we need to iterate because the maximum record count sent back per
      # request is lower than the absolute total number of record.
      if record_total > maximum_record_count
        puts "Iterating through #{record_total} records to retrieve all ..."
        while last_item_id < record_total do
          puts "current offset: #{last_item_id}"
          response = get("#{cases_feature_url}/query", query.merge(resultOffset: last_item_id))
          puts "Count of results: #{response["features"].count}"
          @response_data << response["features"]

          last_item_id = response["features"].last["attributes"]["ObjectId"]
        end
      else
        puts "All records (#{record_total}) can be fetched in a single request!"
      end

      case_death_report = generate_deaths_by_county_from_case_report(
        @response_data
      )

      case_report = generate_case_report(
        @response_data,
        initialize_store(case_keys)
      )

      merged_data = {
        edited_at: last_edit,
        fetched_at: Time.now,
        data: case_report,
        death_data: case_death_report
      }

      save_in_cache case_cache_key, merged_data
    end
  end

  def self.save_in_cache(cache_key, data, expiration_time = Time.now)
    write_cache(cache_key, data)
    set_expiration(cache_key, Time.now + (CACHE_EXPIRATION_IN_MINUTES * 60))
    check_cache(cache_key)
  end

  def self.generate_totals_report(data, store)
    a = data.first["attributes"]

    totals_keys.each_with_object(store) do |(key, value), store|
      if value[:total]
        store[key][:value] = a[value[:source]]
      else
        store[key][:value] += a[value[:source]] || 0
      end
    end
  end

  def self.generate_deaths_by_county_report(data)
    data.map do |d|
      a = d["attributes"]

      { county: a["COUNTYNAME"], deaths: a["FLResDeaths"] }
    end
  end

  def self.generate_county_report(data, store)
    data.each_with_object(store) do |item, memo|
      a = item["attributes"]

      county_keys.each do |key, value|
        if value[:total]
          memo[key][:value] = a[value[:source]]
        else
          memo[key][:value] += a[value[:source]] || 0
        end
      end
    end
  end

  def self.generate_deaths_by_county_from_case_report(data)
    key = case_keys[:deaths]
    deaths_only = data.select { _1["attributes"][key[:source]] == key[:positive_value] }
    deaths_only.group_by { _1["attributes"]["County"] }.map do
      { county: _1.first, deaths: _1.last["attributes"][key[:source]] }
    end
  end

  def self.generate_case_report(data, store)
    data.each_with_object(store) do |item, store|
      a = item["attributes"]

      case_keys.each do |key, value|
        if value[:count_of_total_records]
          store[key][:value] = data.count
        elsif value[:total]
          store[key][:value] = a[value[:source]]
        elsif value[:positive_value]
          positive_value = a[value[:source]] == value[:positive_value]
          store[key][:value] += 1 if positive_value
        else
          store[key][:value] += a[value[:source]] || 0
        end
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
