require 'rubygems'
require 'bundler'

Bundler.require(:development)

require "net/http"
require "json"
require "csv"
require "date"

files = Dir.glob("/Volumes/olivierlacan/dev/oss/florida-department-of-health-covid-19-report-archive/long_term_care_facilities/deaths/*.pdf").sort
latest_pdf = files.last
# https://regex101.com/r/NpdYLG/4
table_regex = /^(.*)\s+(\d+)\s+(\d+)\s+(\d+)$/m.freeze
extra_space_regex = /\s{2,}/.freeze

reader = PDF::Reader.new(latest_pdf)
rows = 0

aggregates = { deaths: 0, resident_deaths: 0, staff_deaths: 0 }

CSV.open("exports/#{Pathname.new(latest_pdf).basename(".pdf")}_#{Time.now.strftime("%Y-%m-%d_%Hh%Mm%Ss")}_parsed.csv", "wb") do |csv|
  csv << ["Facility Name", "County", "Total Deaths", "Deaths in Residents", "Deaths in Staff"]

  reader.pages.each do |page|
    text = page.text
    if text.match? table_regex
      lines = text.lines
      matching_rows = lines.grep(table_regex)
      rows += matching_rows.size
      puts "Page #{page.number}: #{matching_rows.size} rows from #{lines.size} lines. (#{rows} total)"

      matching_rows.each do |row|
        parsed_row = row.strip.split(extra_space_regex)
        facility, county, deaths, residents, staff = *parsed_row
        aggregates[:deaths] += deaths.to_i
        aggregates[:resident_deaths] += residents.to_i
        aggregates[:staff_deaths] += staff.to_i

        csv << parsed_row
      end
    else
      puts "This page didn't match #{page.inspect}"
    end
  end
  puts aggregates
  puts "=== Done. Processed a total of #{rows} rows"
end



