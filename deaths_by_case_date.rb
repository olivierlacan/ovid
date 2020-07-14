# frozen_string_literal: true

require "net/http"
require "json"
require "csv"
require "date"
require "time"

require "./config/boot"
require "./states/state"
require "./states/florida"
require "redis"

cache_key = "raw_case_line_florida_data".freeze
cached_response = Florida.check_cache(cache_key)
raw_data = nil

if cached_response
  raw_data = cached_response
else
  case_worker = CaseDataWorker.new
  case_worker.perform(Florida.cases_feature_url, Florida.case_cache_key, "Florida")
  raw_data = case_worker.case_response_data

  Florida.save_in_cache(cache_key, raw_data)
end

CSV.open("exports/deaths_by_case_date_#{Time.now.strftime("%Y-%m-%d_%Hh%Mm%Ss")}.csv", "wb") do |csv|
  csv << ["CaseDate", "Count"]

  case_dates = raw_data[:features].filter { _1[:attributes][:Died] == "Yes" }.sort_by { _1[:attributes][:Case1] }.group_by { _1[:attributes][:Case1] }

  first_date = DateTime.strptime(case_dates.keys.first.to_s, "%Q").to_date
  last_date = DateTime.strptime(case_dates.keys.last.to_s, "%Q").to_date
  dates = (first_date..last_date).to_a

  dates.each do |date|
    puts date
    case_date = nil
    matching_record = case_dates.find do |key, value|
      case_date = DateTime.strptime(key.to_s, "%Q").to_date
      case_date == date
    end

    csv << [
      case_date,
      matching_record&.last&.count || 0
    ]
  end
end
