require "net/http"
require "json"
require "csv"
require "date"
require "time"

timestamp = DateTime.now.strftime("%Y-%m-%d_%Hh%Mm%Ss")


deaths_uri = URI "https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/arcgis/rest/services/Florida_COVID_19_Deaths_by_Day/FeatureServer/0/query?where=1%3D1&objectIds=&time=&resultType=standard&outFields=*&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnDistinctValues=false&cacheHint=false&orderByFields=Date&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&sqlFormat=none&f=pjson&token="
deaths_raw = Net::HTTP.get(deaths_uri)
deaths_json = JSON.parse(deaths_raw)

first_date = DateTime.strptime(deaths_json["features"].first["attributes"]["Date"].to_s, "%Q").to_date
last_date = DateTime.strptime(deaths_json["features"].last["attributes"]["Date"].to_s, "%Q").to_date

dates = (first_date..last_date).to_a

CSV.open("exports/deaths_by_day_export_#{timestamp}.csv", "wb") do |csv|
  csv << deaths_json["fields"].map { _1["name"] }

  dates.each do |date|
    matching_record = deaths_json["features"].find do
      event_date = DateTime.strptime(_1["attributes"]["Date"].to_s, "%Q").to_date
      event_date == date
    end

    csv << [
      date.iso8601,
      matching_record ? matching_record["attributes"]["Deaths"] : 0,
    ]
  end
end
