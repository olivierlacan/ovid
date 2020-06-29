require "net/http"
require "json"
require "csv"
require "date"
require "time"

require "./states/state"
require "./states/florida"
require "redis"

Florida.get_case_data
case_line_data = Florida.case_response_data

# case_line_data_uri = URI "https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/arcgis/rest/services/Florida_COVID19_Case_Line_Data/FeatureServer/0/query?where=1%3D1&objectIds=&time=&resultType=none&outFields=*&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&sqlFormat=none&f=pjson&token="
# case_line_data_raw = Net::HTTP.get(case_line_data_uri)
# case_line_data_json = JSON.parse(case_line_data_raw)

# {
#   County: "Duval",
#   Age: "21",
#   Age_group: "15-24 years",
#   Gender: "Female",
#   Jurisdiction: "FL resident",
#   Travel_related: "No",
#   Origin: "NA",
#   EDvisit: "YES",
#   Hospitalized: "UNKNOWN",
#   Died: "NA",
#   Case_: "Yes",
#   Contact: "NO",
#   Case1: 1585630800000,
#   EventDate: 1584403200000,
#   ChartDate: 1585630800000,
#   ObjectId: 1
# }

CSV.open("exports/case_line_data_#{Time.now.strftime("%Y-%m-%d_%Hh%Mm%Ss")}.csv", "wb") do |csv|
  csv << case_line_data[:fields].map { _1["name"] }

  case_line_data[:features].each do |record|
    csv << record["attributes"].values
  end
end

CSV.open("exports/deaths_#{Time.now.strftime("%Y-%m-%d_%Hh%Mm%Ss")}.csv", "wb") do |csv|
  csv << ["EventDate", "ChartDate", "Died", "Age", "Gender", "County", "Jurisdiction", "EDvisit", "Hospitalized", "Travel Related"]

  case_line_data[:features].filter { _1["attributes"]["Died"] == "Yes" }.sort_by { _1["attributes"]["Age"]}.each do |record|
    a = record["attributes"]

    csv << [
      Time.strptime(a["EventDate"].to_s, "%Q"),
      Time.strptime(a["ChartDate"].to_s, "%Q"),
      a["Died"],
      a["Age"],
      a["Gender"],
      a["County"],
      a["Jurisdiction"],
      a["EDvisit"],
      a["Hospitalized"],
      a["Travel_related"]
    ]
  end
end

