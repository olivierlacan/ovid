# frozen_string_literal: true

require "date"
require "time"
require "net/http"
require "json"

require "./lib/request"
require "./workers/case_data_worker"

class State
  include Comparable

  CACHE_EXPIRATION_IN_MINUTES = 60
  @@state_classes = []

  class << self
    attr_reader :case_response_data
    attr_reader :county_response_data
  end

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

  def self.hospitals_url
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

  def self.hospitals_keys
    nil
  end

  def self.hospitals_csv_keys
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

  def self.hospitals_cache_key
    "#{cache_key}-hospitals-report"
  end

  def self.case_data_cached?
    check_cache(case_cache_key).present?
  end

  def self.county_report(query_string)
    stored_response = check_cache(county_cache_key)

    if stored_response
      puts "Using stored_response..."
      stored_response
    else
      puts "Generating new report ..."
      get_county_data
    end
  end

  def self.case_report(query_string)
    stored_response = check_cache(case_cache_key)

    if stored_response
      puts "Using stored_response..."
      stored_response
    else
      puts "Generating new report ..."
      job_id = get_case_data

      return { refreshing: true }

      check_cache(case_cache_key)
    end
  end

  def self.totals_report(query_string)
    stored_response = check_cache(totals_cache_key)

    if stored_response
      puts "Using stored_response..."
      stored_response
    else
      puts "Generating new report ..."
      get_totals_data
    end
  end

  def self.hospitals_report(query_string)
    stored_response = check_cache(hospitals_cache_key)

    if stored_response
      puts "Using stored_response..."
      stored_response
    else
      puts "Generating new report ..."
      get_hospitals_data
    end
  end

  def self.get_csv(url)
    uri = URI(url)
    puts "Sending GET request to #{uri} ..."
    response = Net::HTTP.get_response(uri)
    if response.is_a?(Net::HTTPSuccess)
      puts "Success!"
      JSON.parse(response.body, symbolize_names: true)
    else
      raise "#{response.code}: #{response.message}"
      puts "Headers: #{res.to_hash.inspect}"
      puts res.body if response.response_body_permitted?
    end
  end

  def self.last_edit(metadata)
    raw_edit_date = metadata[:editingInfo][:lastEditDate]
    converted_edit_date = Time.strptime(raw_edit_date.to_s, "%Q")
    puts "Parsed lastEditDate #{raw_edit_date} converted to #{converted_edit_date} (#{ENV["TZ"]})"

    converted_edit_date
  end

  def self.get_totals_data
    if totals_keys
      metadata = Request.get(totals_feature_url)
      last_edit = last_edit(metadata)

      query = {
        where: "1=1",
        returnGeometry: false,
        outFields: "*",
        resultType: "standard"
      }

      response = Request.get("#{totals_feature_url}/query", query)

      totals_report = generate_totals_report(
        response[:features],
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

  def self.get_hospitals_data
    if hospitals_keys
      metadata = Request.get(hospitals_feature_url)
      last_edit = last_edit(metadata)

      query = {
        where: "1=1",
        returnGeometry: false,
        outFields: "*",
        resultType: "standard"
      }

      response = Request.get("#{hospitals_feature_url}/query", query)

      hospitals_report = generate_hospitals_report(
        response[:features],
        initialize_store(hospitals_keys)
      )
    elsif hospitals_csv_keys
      require 'csv'
      require 'open-uri'

      response = get_csv(hospitals_csv_url)

      CSV.read(response, headers: :first_row, col_sep: "  ")

      last_edit = last_edit(metadata)

      hospitals_report = generate_hospitals_report(
        response[:features],
        initialize_store(hospitals_keys)
      )
    end

    merged_data = {
      edited_at: last_edit,
      fetched_at: Time.now,
      data: hospitals_report
    }

    save_in_cache hospitals_cache_key, merged_data
  end

  def self.get_county_data
    if county_keys
      metadata = Request.get(counties_feature_url)
      last_edit = last_edit(metadata)

      query = {
        where: "1=1",
        returnGeometry: false,
        outFields: "*",
        resultType: "standard"
      }

      response = Request.get("#{counties_feature_url}/query", query)

      @county_response_data = { fields: response[:fields], features: [] }
      @county_response_data[:features].push(*response[:features])

      county_report = generate_county_report(
        @county_response_data[:features],
        initialize_store(county_keys)
      )
    end

    merged_data = {
      edited_at: last_edit,
      fetched_at: Time.now,
      data: county_report
    }

    save_in_cache county_cache_key, merged_data
  end

  def self.total_records_from_feature(url, query)
    Request.get("#{url}/query", query.merge({ returnCountOnly: true }))[:count]
  end

  def self.get_case_data
    if cases_feature_url
      worker = CaseDataWorker.perform_async(cases_feature_url, case_cache_key, self)
    end
  end

  def self.save_in_cache(cache_key, data, expiration_time = Time.now)
    write_cache(cache_key, data)
    set_expiration(cache_key, Time.now + (CACHE_EXPIRATION_IN_MINUTES * 60))
    check_cache(cache_key)
  end

  def self.generate_hospitals_report(data, store)
    data.each_with_object(store) do |item, memo|
      a = item[:attributes]

      hospitals_keys.each do |key, value|
        if value[:total]
          memo[key][:value] = a[value[:source]]
        else
          memo[key][:value] += a[value[:source]] || 0
        end
      end
    end
  end

  def self.generate_totals_report(data, store)
    a = data.first[:attributes]

    totals_keys.each_with_object(store) do |(key, value), store|
      if value[:total]
        store[key][:value] = a[value[:source]]
      else
        store[key][:value] += a[value[:source]] || 0
      end
    end
  end

  def self.generate_county_report(data, store)
    data.each_with_object(store) do |item, memo|
      a = item[:attributes]

      county_keys.each do |key, value|
        if value[:total]
          memo[key][:value] = a[value[:source]]
        else
          memo[key][:value] += a[value[:source]].to_i || 0
        end
      end
    end
  end

  def self.generate_case_report(data, store)
    data.each_with_object(store) do |item, store|
      a = item[:attributes]

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
