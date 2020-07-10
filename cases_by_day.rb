# frozen_string_literal: true

require "net/http"
require "json"
require "csv"
require "date"
require "time"

timestamp = DateTime.now.strftime("%Y-%m-%d_%Hh%Mm%Ss")

cases_by_day_uri = URI "https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/ArcGIS/rest/services/Florida_COVID_19_Cases_by_Day_For_Time_Series/FeatureServer/0/query?where=1%3D1&objectIds=&time=&resultType=standard&outFields=*&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnDistinctValues=false&cacheHint=false&orderByFields=Date&groupByFieldsForStatistics=Date&outStatistics=%5B%7B%0D%0A++++%22statisticType%22%3A+%22sum%22%2C%0D%0A++++%22onStatisticField%22%3A+%22FREQUENCY%22%2C+%0D%0A++++%22outStatisticFieldName%22%3A+%22Count%22%0D%0A%7D%5D&having=&resultOffset=&resultRecordCount=&sqlFormat=standard&f=pjson&token="
cases_by_day_raw = Net::HTTP.get(cases_by_day_uri)
cases_by_day_json = JSON.parse(cases_by_day_raw)

first_date = DateTime.strptime(cases_by_day_json["features"].first["attributes"]["Date"].to_s, "%Q").to_date
last_date = DateTime.strptime(cases_by_day_json["features"].last["attributes"]["Date"].to_s, "%Q").to_date

dates = (first_date..last_date).to_a

CSV.open("exports/cases_by_day_export_#{timestamp}.csv", "wb") do |csv|
  csv << cases_by_day_json["fields"].map { _1["name"] }.reverse

  cases_by_day_json["features"].each do |row|
    a = row["attributes"]

    csv << [
      DateTime.strptime(a["Date"].to_s, "%Q").to_date.iso8601,
      a["Count"] || 0
    ]
  end
end
