# frozen_string_literal: true

require "net/http" # Ruby's standard HTTP request library
require "json" # Ruby's standard JSON parsing library
require "csv" # Ruby's CSV processing library

# Use the URI class to convert the endpoint string into a URI class instance
endpoint = URI "https://covidtracking.com/api/v1/states/daily.json"

# Send a GET request to the endpoint URI
response = Net::HTTP.get(endpoint)

# Parse the response JSON string representation of the data into a native
# Ruby Hash (dictionnary or object in other languages) instance.
data = JSON.parse(response)

# Pretty print the first result in the data array, which happens to be Alaska
pp data.first
{"date"=>20200716,
 "state"=>"AK",
 "positive"=>2032,
 "negative"=>160990,
 "pending"=>nil,
 # ...
}

# Group the daily results by state abbreviation
states = data.group_by { _1["state"] }

# Find just the data for Florida and collect all days
florida = states.find { |key, value| key == "FL" }.last

# Print data for the most recent day
pp florida.first

{"date"=>20200716,
 "state"=>"FL",
 "positive"=>315775,
 "negative"=>2499843,
 "pending"=>2163,
 # ...
}

# Export Florida data for all days to a CSV file
CSV.open("covid_tracking_project_florida_daily.csv", "wb") do |csv|
  csv << florida.first.keys
  florida.each { csv << _1.values }
end
