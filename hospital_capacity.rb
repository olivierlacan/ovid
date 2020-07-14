# frozen_string_literal: true

require "csv"
require "date"
require "time"

def convert_to_hash(file)
  csv = CSV.read(file, headers: true)
  totals = csv.find_all { |row| row["County"] == "All" }
  updated_at = totals.first["updated"]
  time = DateTime.strptime("#{updated_at}-05:00", '%m/%d/%Y, %H:%M%p%z').strftime("%Y-%m-%d %H:%M")
  output = { "Updated At" => time }
  totals.each_with_object(output) do |row, memo|
    memo[row["Measure Names"]] = row["Measure Values"]
  end
end

timestamp = DateTime.now.strftime("%Y-%m-%d_%Hh%Mm%Ss")
base_path = "/Users/olivierlacan/dev/oss/florida-department-of-health-covid-19-report-archive/AHCA/"
county_hospital_beds = Dir.glob("#{base_path}/fl_ahca_all_beds_county/fl-bed-capacities-counties_*.csv").sort
county_icu_beds = Dir.glob("#{base_path}/fl_ahca_icu_counties/fl-icu-bed-capacities-counties_*.csv").sort

CSV.open("exports/fl-bed-capacities-counties_hourly_#{timestamp}.csv", "wb") do |csv|
  csv << convert_to_hash(county_hospital_beds.first).keys
  county_hospital_beds.each { csv << convert_to_hash(_1).values }
end

CSV.open("exports/fl-icu-bed-capacities-counties_hourly_#{timestamp}.csv", "wb") do |csv|
  csv << convert_to_hash(county_icu_beds.first).keys
  county_icu_beds.each { csv << convert_to_hash(_1).values }
end

CSV.open("exports/fl-bed-capacities-counties_daily_#{timestamp}.csv", "wb") do |csv|
  csv << convert_to_hash(county_hospital_beds.first).keys
  county_hospital_beds.each do
    values = convert_to_hash(_1).values
    csv << values if values[0].include?("16:18") # updates every hour at 18 mins
  end
end

CSV.open("exports/fl-icu-bed-capacities-counties_daily_#{timestamp}.csv", "wb") do |csv|
  csv << convert_to_hash(county_icu_beds.first).keys
  county_icu_beds.each do
    values = convert_to_hash(_1).values
    csv << values if values[0].include?("16:19") # updates every hour at 19 mins
  end
end
