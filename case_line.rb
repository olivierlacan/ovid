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

# {:attributes=>
#   {:County=>"Palm Beach",
#    :Age=>"65",
#    :Age_group=>"65-74 years",
#    :Gender=>"Male",
#    :Jurisdiction=>"FL resident",
#    :Travel_related=>"No",
#    :Origin=>"NA",
#    :EDvisit=>"NO",
#    :Hospitalized=>"YES",
#    :Died=>"NA",
#    :Case_=>"Yes",
#    :Contact=>"Yes",
#    :Case1=>1590901200000,
#    :EventDate=>1590624000000,
#    :ChartDate=>1590901200000,
#    :ObjectId=>1}}

jurisdictions = raw_data[:features].group_by { _1[:attributes][:Jurisdiction] }

@sorted = jurisdictions.each_with_object([]) do |jurisdiction, memo|
  memo << {
    jurisdiction: jurisdiction.first,
    ed_visit: jurisdiction.last.group_by { _1[:attributes][:EDvisit] }.map { |(k,v)| { "#{k.to_s}" => v.size } },
    deaths: jurisdiction.last.group_by { _1[:attributes][:Died] }.map { |(k,v)| { "#{k.to_s}" => v.size } },
    hospitalized: jurisdiction.last.group_by { _1[:attributes][:Hospitalized] }.map { |(k,v)| { "#{k.to_s}" => v.size } },
    total: jurisdiction.last.size
  }
end

def find_yes_count_for(jurisdiction, type)
  @sorted.find { |v| v[:jurisdiction] == jurisdiction}[type].find { |v| v.find { |k,v| k == "YES" } }["YES"]
end

all_cases = raw_data[:features].size
all_hospitalized = raw_data[:features].find_all { _1[:attributes][:Hospitalized] == "YES" }.size
all_ed_visit = raw_data[:features].find_all { _1[:attributes][:EDvisit] == "YES" }.size
all_died = raw_data[:features].find_all { _1[:attributes][:Died] == "Yes" }.size

all_residents = @sorted.find { |v| v[:jurisdiction] == "FL resident"}[:total]
residents_ed_visit = find_yes_count_for("FL resident", :ed_visit)
residents_hospitalized = find_yes_count_for("FL resident", :hospitalized)
residents_deaths = @sorted.find { |v| v[:jurisdiction] == "FL resident"}[:deaths].find { |v| v.find { |k,v| k == "Yes" } }["Yes"]

all_residents_out_of_state = @sorted.find { |v| v[:jurisdiction] == "Not diagnosed/isolated in FL"}[:total]
residents_out_of_state_ed_visit = find_yes_count_for("Not diagnosed/isolated in FL", :ed_visit)
residents_out_of_state_hospitalized = find_yes_count_for("Not diagnosed/isolated in FL", :hospitalized)
residents_out_of_state_deaths = @sorted.find { |v| v[:jurisdiction] == "Not diagnosed/isolated in FL"}[:deaths].find { |v| v.find { |k,v| k == "Yes" } }["Yes"]

all_non_residents = @sorted.find { |v| v[:jurisdiction] == "Non-FL resident"}[:total]
non_residents_ed_visit = find_yes_count_for("Non-FL resident", :ed_visit)
non_residents_hospitalized = find_yes_count_for("Non-FL resident", :hospitalized)
non_residents_deaths = @sorted.find { |v| v[:jurisdiction] == "Non-FL resident"}[:deaths].find { |v| v.find { |k,v| k == "Yes" } }["Yes"]

def perc(subset, total)
  result = (subset.fdiv(total) * 100).round(2)
  "#{result}%"
end

tally = {
  cases: {
    total: all_cases,
    hospitalized: all_hospitalized,
    ed_visit: all_ed_visit,
    died: all_died
  },
  residents_and_diagnosed_out_of_state: {
    total: all_residents + all_residents_out_of_state,
    hospitalized: [residents_hospitalized + residents_out_of_state_hospitalized, perc(residents_hospitalized + residents_out_of_state_hospitalized, all_residents + all_residents_out_of_state)],
    ed_visit: [residents_ed_visit + residents_out_of_state_ed_visit, perc(residents_ed_visit + residents_out_of_state_ed_visit, all_residents + all_residents_out_of_state)],
    died: [residents_deaths + residents_out_of_state_deaths, perc(residents_deaths + residents_out_of_state_deaths, all_residents + all_residents_out_of_state)]
  },
  non_residents: {
    total: all_non_residents,
    hospitalized: [non_residents_hospitalized, perc(non_residents_hospitalized, all_non_residents)],
    ed_visit: [non_residents_ed_visit, perc(non_residents_ed_visit, all_non_residents)],
    died: [non_residents_deaths, perc(non_residents_deaths, all_non_residents)]
  }
}

puts tally

timestamp = DateTime.now.strftime("%Y-%m-%d_%Hh%Mm%Ss")
CSV.open("exports/resident_vs_non_resident_percentages_#{timestamp}.csv", "wb") do |csv|
  csv << ["jurisdiction", *tally[:cases].keys.map(&:to_s).reverse]

  tally.keys.each do |key|
    csv << [key.to_s, *tally[key].values.reverse]
  end
end


# [{:jurisdiction=>"FL resident",
#   :ed_visit=>
#    [{"NO"=>69260},
#     {""=>7211},
#     {"UNKNOWN"=>106689},
#     {"YES"=>27008},
#     {"NA"=>418}],
#   :deaths=>[{"NA"=>206746}, {"Yes"=>3840}],
#   :hospitalized=>
#    [{"YES"=>16423},
#     {"NO"=>88388},
#     {"UNKNOWN"=>102201},
#     {""=>3157},
#     {"NA"=>417}]},
#  {:jurisdiction=>"Non-FL resident",
#   :ed_visit=>[{"UNKNOWN"=>2095}, {"NO"=>449}, {"YES"=>453}, {""=>203}],
#   :deaths=>[{"NA"=>3098}, {"Yes"=>102}],
#   :hospitalized=>[{"UNKNOWN"=>2174}, {"NO"=>674}, {"YES"=>308}, {""=>44}]},
#  {:jurisdiction=>"Not diagnosed/isolated in FL",
#   :ed_visit=>[{"NO"=>4}, {""=>2}, {"YES"=>2}],
#   :deaths=>[{"NA"=>7}, {"Yes"=>1}],
#   :hospitalized=>[{"YES"=>2}, {"NO"=>4}, {"UNKNOWN"=>2}]}]



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

# CSV.open("exports/case_line_data_#{Time.now.strftime("%Y-%m-%d_%Hh%Mm%Ss")}.csv", "wb") do |csv|
#   csv << case_line_data[:fields].map { _1["name"] }

#   case_line_data[:features].each do |record|
#     csv << record["attributes"].values
#   end
# end

# CSV.open("exports/deaths_#{Time.now.strftime("%Y-%m-%d_%Hh%Mm%Ss")}.csv", "wb") do |csv|
#   csv << ["EventDate", "ChartDate", "Died", "Age", "Gender", "County", "Jurisdiction", "EDvisit", "Hospitalized", "Travel Related"]

#   case_line_data[:features].filter { _1["attributes"]["Died"] == "Yes" }.sort_by { _1["attributes"]["Age"]}.each do |record|
#     a = record["attributes"]

#     csv << [
#       Time.strptime(a["EventDate"].to_s, "%Q"),
#       Time.strptime(a["ChartDate"].to_s, "%Q"),
#       a["Died"],
#       a["Age"],
#       a["Gender"],
#       a["County"],
#       a["Jurisdiction"],
#       a["EDvisit"],
#       a["Hospitalized"],
#       a["Travel_related"]
#     ]
#   end
# end

