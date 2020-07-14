# frozen_string_literal: true

require "csv"
require "date"
require "time"
require "digest"
require "pathname"

unless ARGV[0]
  abort <<~STRING
    Pass filename of CSV to reprocess as argument.
    Example:
      ruby reprocess_case_line.rb case_line_data_2020-03-30_11h12m24s.csv
  STRING
end

filename = Pathname.new(ARGV[0]).basename.sub_ext('')

CSV.open("exports/#{filename}_reprocessed_#{Time.now.strftime("%Y-%m-%d_%Hh%Mm%Ss")}.csv", "wb") do |csv|
  cases = CSV.read(ARGV[0], headers: true, header_converters: :symbol)

  headers = cases.headers.reverse.reject do
    [:age_group, :chartdate].include?(_1) ||
    _1 == :case_ && !cases.first[:case_].match?(/\d+/)
  end
  csv << ["MD5fingerprint", *headers]

  cases.each do |row|
    a = row.to_h
    obj_id = a.delete(:objectid)

    event_date = DateTime.strptime(a.delete(:eventdate).to_s, "%Q").to_date.iso8601
    # older case line data has Case_ as a timestamp equivalent to ChartDate or
    # when the case became a case for FDOH, not symptom onset or lab result date
    case_date = if a[:case_]&.match?(/\d+/)
      DateTime.strptime(a.delete(:case_).to_s, "%Q").to_date.iso8601
    else
      DateTime.strptime(a.delete(:case1).to_s, "%Q").to_date.iso8601
    end
    fingerprint = Digest::MD5.hexdigest "#{a[:age]}#{a[:gender]}#{a[:county]}#{a[:jurisdiction]}#{event_date}#{case_date}"

    a[:age_group] && a.delete(:age_group)
    a[:case_]&.match?(/Yes/) && a.delete(:case_)
    a[:chartdate] && a.delete(:chartdate)

    csv << [fingerprint, obj_id, event_date, case_date, *a.values.reverse]
  end
end
