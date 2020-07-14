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

CSV.open("exports/case_line_data_#{Time.now.strftime("%Y-%m-%d_%Hh%Mm%Ss")}.csv", "wb") do |csv|
  csv << raw_data[:fields].map { _1[:name] }

  raw_data[:features].each do |record|
    csv << record[:attributes].values
  end
end

