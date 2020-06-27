require "net/http"
require "json"
require "csv"
require "date"
require "time"

uri = URI "https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/arcgis/rest/services/Florida_COVID19_Case_Line_Data_NEW/FeatureServer/0/query?where=1%3D1&objectIds=&time=&resultType=standard&outFields=*&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnDistinctValues=false&cacheHint=false&orderByFields=EventDate&groupByFieldsForStatistics=EventDate&outStatistics=%5B%7B%0D%0A++++%22statisticType%22%3A+%22count%22%2C%0D%0A++++%22onStatisticField%22%3A+%22OBJECTID%22%2C+%0D%0A++++%22outStatisticFieldName%22%3A+%22Count%22%0D%0A%7D%5D&having=&resultOffset=&resultRecordCount=&sqlFormat=none&f=pjson&token="
raw = Net::HTTP.get(uri)
json = JSON.parse(raw)

timestamp = DateTime.now.strftime("%Y-%m-%d_%Hh%Mm%Ss")

first_date = DateTime.strptime(json["features"].first["attributes"]["EventDate"].to_s, "%Q").to_date
last_date = DateTime.strptime(json["features"].last["attributes"]["EventDate"].to_s, "%Q").to_date

dates = (first_date..last_date).to_a

CSV.open("exports/event_date_grouped_#{timestamp}.csv", "wb") do |csv|
  csv << ["EventDate", "Count"]

  dates.each do |date|
    matching_record = json["features"].find do
      event_date = DateTime.strptime(_1["attributes"]["EventDate"].to_s, "%Q").to_date

      event_date == date
    end

    csv << [
      date.iso8601,
      matching_record ? matching_record["attributes"]["Count"] : nil
    ]
  end
end

case_date_uri = URI "https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/arcgis/rest/services/Florida_COVID19_Case_Line_Data_NEW/FeatureServer/0/query?where=1%3D1&objectIds=&time=&resultType=standard&outFields=*&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnDistinctValues=false&cacheHint=false&orderByFields=Case1&groupByFieldsForStatistics=Case1&outStatistics=%5B%7B%0D%0A++++%22statisticType%22%3A+%22count%22%2C%0D%0A++++%22onStatisticField%22%3A+%22OBJECTID%22%2C+%0D%0A++++%22outStatisticFieldName%22%3A+%22Count%22%0D%0A%7D%5D&having=&resultOffset=&resultRecordCount=&sqlFormat=none&f=pjson&token="
case_date_raw = Net::HTTP.get(case_date_uri)
case_date_json = JSON.parse(case_date_raw)

CSV.open("exports/event_date_grouped_by_case_date_#{timestamp}.csv", "wb") do |csv|
  csv << ["CaseDate", "Count"]

  dates.each do |date|
    matching_record = case_date_json["features"].find do
      event_date = DateTime.strptime(_1["attributes"]["Case1"].to_s, "%Q").to_date

      event_date == date
    end

    csv << [
      date.iso8601,
      matching_record ? matching_record["attributes"]["Count"] : nil
    ]
  end
end

case_by_day_uri = URI "https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/ArcGIS/rest/services/Florida_COVID_19_Cases_by_Day_For_Time_Series/FeatureServer/0/query?where=1%3D1&objectIds=&time=&resultType=standard&outFields=*&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnDistinctValues=false&cacheHint=false&orderByFields=Date&groupByFieldsForStatistics=Date&outStatistics=%5B%7B%0D%0A++++%22statisticType%22%3A+%22sum%22%2C%0D%0A++++%22onStatisticField%22%3A+%22FREQUENCY%22%2C+%0D%0A++++%22outStatisticFieldName%22%3A+%22Count%22%0D%0A%7D%5D&having=&resultOffset=&resultRecordCount=&sqlFormat=none&f=json&token="
case_by_day_raw = Net::HTTP.get(case_by_day_uri)
case_by_day_json = JSON.parse(case_by_day_raw)

CSV.open("exports/cases_by_day_with_aggregated_frequency_#{timestamp}.csv", "wb") do |csv|
  csv << ["Date", "Count"]

  dates.each do |date|    
    matching_record = case_by_day_json["features"].find do
      event_date = DateTime.strptime(_1["attributes"]["Date"].to_s, "%Q").to_date

      event_date == date
    end

    csv << [
      date.iso8601,
      matching_record ? matching_record["attributes"]["Count"] : nil
    ]
  end
end

deaths_uri = URI "https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/arcgis/rest/services/Florida_COVID_19_Deaths_by_Day/FeatureServer/0/query?where=1%3D1&objectIds=&time=&resultType=standard&outFields=*&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnDistinctValues=false&cacheHint=false&orderByFields=Date&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&sqlFormat=none&f=pjson&token="
deaths_raw = Net::HTTP.get(deaths_uri)
deaths_json = JSON.parse(deaths_raw)

CSV.open("exports/deaths_by_day_export_#{timestamp}.csv", "wb") do |csv|
  csv << deaths_json["fields"].map { _1["name"] }

  dates.each do |date|
    matching_record = deaths_json["features"].find do
      event_date = DateTime.strptime(_1["attributes"]["Date"].to_s, "%Q").to_date

      event_date == date
    end

    csv << [
      date.iso8601,
      matching_record ? matching_record["attributes"]["Deaths"] : nil,
      matching_record ? matching_record["attributes"]["ObjectId"] : nil
    ]
  end
end
