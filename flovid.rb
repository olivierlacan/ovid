require "date"
require "net/http"
require "json"

class Flovid
  TESTING_URL = "https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/arcgis/rest/services/Florida_Testing/FeatureServer/0/query?where=1%3D1&objectIds=&time=&resultType=none&outFields=*&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&sqlFormat=none&f=pjson&token="

  def self.covid_tracking_report
    uri = URI(TESTING_URL)
    response = Net::HTTP.get(uri)
    parsed_response = JSON.parse(response)

    generate_report parsed_response["features"]
  end

  def self.generate_report(testing_data)
    # Example testing_data:
    #
    # {"OBJECTID_12_13"=>1,
    #  "OBJECTID"=>1,
    #  "DEPCODE"=>21,
    #  "COUNTY"=>"041",
    #  "COUNTYNAME"=>"GILCHRIST",
    #  "DATESTAMP"=>"2000-05-16T00:00:00.000Z",
    #  "ShapeSTAre"=>9908353355.45099,
    #  "ShapeSTLen"=>487300.011359113,
    #  "OBJECTID_1"=>21,
    #  "County_1"=>"Gilchrist",
    #  "State"=>"FL",
    #  "OBJECTID_12"=>"1",
    #  "DEPCODE_1"=>21,
    #  "COUNTYN"=>"41",
    #  "PUIsTotal"=>32,
    #  "Age_0_4"=>3,
    #  "Age_5_14"=>0,
    #  "Age_15_24"=>4,
    #  "Age_25_34"=>3,
    #  "Age_35_44"=>7,
    #  "Age_45_54"=>3,
    #  "Age_55_64"=>3,
    #  "Age_65_74"=>3,
    #  "Age_75_84"=>4,
    #  "Age_85plus"=>2,
    #  "Age_Unkn"=>0,
    #  "C_Age_0_4"=>0,
    #  "C_Age_5_14"=>0,
    #  "C_Age_15_24"=>0,
    #  "C_Age_25_34"=>0,
    #  "C_Age_35_44"=>0,
    #  "C_Age_45_54"=>0,
    #  "C_Age_55_64"=>0,
    #  "C_Age_65_74"=>0,
    #  "C_Age_75_84"=>0,
    #  "C_Age_85plus"=>0,
    #  "PUIAgeAvrg"=>"0",
    #  "PUIAgeRange"=>"0 to 89",
    #  "C_AgeAvrg"=>"46",
    #  "C_AgeRange"=>"NA",
    #  "C_AllResTypes"=>0,
    #  "C_NonResDeaths"=>0,
    #  "PUIFemale"=>17,
    #  "PUIMale"=>15,
    #  "PUISexUnkn"=>0,
    #  "PUIFLRes"=>32,
    #  "PUINotFLRes"=>0,
    #  "PUIFLResOut"=>0,
    #  "PUITravelNo"=>5,
    #  "PUITravelUnkn"=>27,
    #  "PUITravelYes"=>0,
    #  "C_ED_NO"=>0,
    #  "C_ED_NoData"=>0,
    #  "C_ED_Yes"=>0,
    #  "C_Hosp_No"=>0,
    #  "C_Hosp_Nodata"=>0,
    #  "C_Hosp_Yes"=>0,
    #  "FLResDeaths"=>0,
    #  "PUILab_Yes"=>32,
    #  "TPositive"=>0,
    #  "TNegative"=>32,
    #  "TInconc"=>0,
    #  "TPending"=>0,
    #  "PUIContNo"=>1,
    #  "PUIContUnkn"=>2,
    #  "PUIContYes"=>0,
    #  "CasesAll"=>0,
    #  "C_Men"=>0,
    #  "C_Women"=>0,
    #  "C_FLRes"=>0,
    #  "C_NotFLRes"=>0,
    #  "C_FLResOut"=>0,
    #  "T_NegRes"=>32,
    #  "T_NegNotFLRes"=>0,
    #  "T_total"=>32,
    #  "T_negative"=>32,
    #  "T_positive"=>0,
    #  "Deaths"=>0,
    #  "EverMon"=>0,
    #  "MonNow"=>0,
    #  "Shape__Area"=>0.0858306455302227,
    #  "Shape__Length"=>1.42926667474908}
    #

    testing_totals = relevant_keys.each_with_object({}) do |(key, description), store|
      store[key] = { value: 0, name: description }
    end

    testing_data.each_with_object(testing_totals) do |test, store|
      a = test["attributes"]

      store[:cumulative_hospitalized][:value] += a["C_Hosp_Yes"]
      store[:PUIs_total][:value] += a["PUIsTotal"]
      store[:PUIs_residents][:value] += a["PUIFLRes"]
      store[:PUIs_non_residents][:value] += a["PUINotFLRes"]
      store[:PUIs_residents_out][:value] += a["PUIFLResOut"]
      store[:deaths_non_residents][:value] += a["C_NonResDeaths"]
      store[:deaths_residents][:value] += a["FLResDeaths"]
      store[:positive_no_emergency_admission][:value] += a["C_ED_NO"]
      store[:positive_emergency_admission][:value] += a["C_ED_Yes"]
      store[:positive_unknown_emergency_admission][:value] += a["C_ED_NoData"]
      store[:positives_total_quality][:value] += a["TPositive"]
      # T_Positive can be nil, hence the `|| 0` to prevent coercion errors
      store[:positives_total][:value] += a["T_Positive"] || 0
      store[:negatives_total_quality][:value] += a["TNegative"]
      store[:negatives_total][:value] += a["T_negative"]
      store[:inconclusive_total][:value] += a["TInconc"]
      store[:pending_total][:value] += a["T_pending"] || 0
      store[:pending_total_quality][:value] += a["TPending"]
      store[:tests_total][:value] += a["T_total"]
      store[:monitored_cumulative][:value] += a["EverMon"]
      store[:monitored_currently][:value] += a["MonNow"]
    end
  end

  def self.relevant_keys
    {
      cumulative_hospitalized: "Hospitalized (cumulative)",
      PUIs_total: "PUIs - Total",
      PUIs_residents: "PUI - Residents",
      PUIs_non_residents: "PUI - Non-residents",
      PUIs_residents_out: "PUI - Residents Out of State",
      deaths_non_residents: "Deaths - Non-residents",
      deaths_residents: "Deaths - Residents",
      positive_no_emergency_admission: "Positive Tests - No ER Admission",
      positive_emergency_admission: "Positive Tests - ER Admission",
      positive_unknown_emergency_admission: "Positive Tests - Unknown ER Admission",
      positives_total_quality: "Positive Tests - Total (Quality Control)",
      positives_total: "Positive Tests - Total",
      negatives_total_quality: "Negative Tests - Total (Quality Control)",
      negatives_total: "Negative Tests - Total",
      inconclusive_total: "Inconclusive Test Results - Total",
      pending_total: "Pending Tests - Total",
      pending_total_quality: "Pending Tests - Total (Quality Control)",
      tests_total: "Tests - Total",
      monitored_cumulative: "Monitored - Cumulative Total",
      monitored_currently: "Monitored - Current Total"
    }
  end

  def self.production?
    ENV["RACK_ENV"] == "production"
  end

  def self.development?
    !production?
  end

  def self.cache
    @redis ||= if production?
      Redis.new(url: ENV["REDIS_URL"])
    else
      Redis.new
    end
  end
end
