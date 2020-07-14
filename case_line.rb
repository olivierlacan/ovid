# frozen_string_literal: true

require "net/http"
require "json"
require "csv"
require "date"
require "time"
require "digest"

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
  headers = raw_data[:fields].map { _1[:name].downcase.to_sym }.reverse.reject do
    [:age_group, :chartdate].include?(_1) ||
    _1 == :case_ && !raw_data[:features].first[:attributes][:Case_].match?(/\d+/)
  end
  csv << ["MD5fingerprint", *headers]

  raw_data[:features].sort_by { _1[:attributes][:EventDate] }.each do |record|
    a = record[:attributes]
    obj_id = a.delete(:ObjectId)
    chart_date = DateTime.strptime(a.delete(:ChartDate).to_s, "%Q").to_date.iso8601
    event_date = DateTime.strptime(a.delete(:EventDate).to_s, "%Q").to_date.iso8601
    case_date = DateTime.strptime(a.delete(:Case1).to_s, "%Q").to_date.iso8601
    fingerprint = Digest::MD5.hexdigest "#{a[:Age]}#{a[:Gender]}#{a[:County]}#{a[:Jurisdiction]}#{event_date}#{case_date}"

    a[:Age_group] && a.delete(:Age_group)
    a[:Case_]&.match?(/Yes/) && a.delete(:Case_)
    a[:ChartDate] && a.delete(:ChartDate)

    csv << [fingerprint, obj_id, chart_date, event_date, case_date, *record[:attributes].values.reverse]
  end
end

