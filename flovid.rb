require "date"
require "net/http"
require "json"

class Flovid
  TESTING_URL = "https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/arcgis/rest/services/Florida_Testing/FeatureServer/0/query?where=1%3D1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=false&returnCentroid=false&featureEncoding=esriDefault&multipatchOption=none&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pjson&token="

  def self.covid_tracking_report
    cache_key = "covid_testing_payload"

    stored_response = check_cache(cache_key)

    if stored_response
      puts "Using stored_response: \n#{stored_response.inspect}"
      stored_response
    else
      puts "Generating new report ..."
      uri = URI(TESTING_URL)
      response = Net::HTTP.get(uri)
      parsed_response = JSON.parse(response)

      report = generate_report(parsed_response["features"])

      write_cache(cache_key, report)

      check_cache(cache_key)
    end
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

    testing_totals = relevant_keys.each_with_object({}) do |(key, metric), store|
      store[key] = {
        value: 0,
        name: metric[:name],
        highlight: metric[:highlight],
        source: metric[:source]
      }
    end

    testing_data.each_with_object(testing_totals) do |test, store|
      a = test["attributes"]

      relevant_keys.each do |key, value|
        store[key][:value] += a[value[:source]] || 0
      end
    end
  end

  def self.relevant_keys
    {
      PUIs_total: {
        name: "PUIs - Total",
        highlight: false,
        source: "PUIsTotal"
      },
      PUIs_residents: {
        name: "PUI - Residents",
        highlight: false,
        source: "PUIFLRes"
      },
      PUIs_non_residents: {
        name: "PUI - Non-residents",
        highlight: false,
        source: "PUINotFLRes"
      },
      PUIs_residents_out: {
        name: "PUI - Residents Out of State",
        highlight: false,
        source: "PUIFLResOut"
      },
      deaths_non_residents: {
        name: "Deaths - Non-residents",
        highlight: false,
        source: "C_NonResDeaths"
      },
      deaths_residents: {
        name: "Deaths - Residents",
        highlight: false,
        source: "FLResDeaths"
      },
      positive_no_emergency_admission: {
        name: "Positive Tests - No ER Admission",
        highlight: false,
        source: "C_ED_NO"
      },
      positive_emergency_admission: {
        name: "Positive Tests - ER Admission",
        highlight: false,
        source: "C_ED_Yes"
      },
      positive_unknown_emergency_admission: {
        name: "Positive Tests - Unknown ER Admission",
        highlight: false,
        source: "C_ED_NoData"
      },
      positives_total_quality: {
        name: "Positive Tests - Total (Quality Control)",
        highlight: false,
        source: "TPositive"
      },
      negatives_total_quality: {
        name: "Negative Tests - Total (Quality Control)",
        highlight: false,
        source: "TNegative"
      },
      inconclusive_total: {
        name: "Inconclusive Test Results - Total",
        highlight: false,
        source: "TInconc"
      },
      monitored_cumulative: {
        name: "Monitored - Cumulative Total",
        highlight: false,
        source: "EverMon"
      },
      monitored_currently: {
        name: "Monitored - Current Total",
        highlight: false,
        source: "MonNow"
      },
      positives_total: {
        name: "Positive Tests - Total",
        highlight: true,
        source: "T_positive"
      },
      negatives_total: {
        name: "Negative Tests - Total",
        highlight: true,
        source: "T_negative"
      },
      pending_total: {
        name: "Pending Tests - Total",
        highlight: true,
        source: "TPending"
      },
      cumulative_hospitalized: {
        name: "Hospitalized (cumulative)",
        highlight: true,
        source: "C_Hosp_Yes"
      },
      tests_total: {
        name: "Tests - Total",
        highlight: true,
        source: "T_total"
      }
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

  def self.check_cache(key)
    payload = cache.get(key)

    if payload
      puts "cache hit for #{key}"
      JSON.parse(payload, { symbolize_names: true })
    else
      puts "cache miss for #{key}"
    end
  end

  def self.write_cache(key, value)
    puts "cache write for #{key}"
    payload = value.to_json
    puts "caching serialized payload: #{payload.inspect}"

    cache.multi do
      cache.set(key, payload)
      cache.get(key)
    end
  end
end
