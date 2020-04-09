require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class Texas < State
  DEPARTMENT = "Texas State Department of Health"
  ACRONYM = "TDSHS"

  def self.counties_feature_url
    "https://services5.arcgis.com/ACaLB9ifngzawspq/arcgis/rest/services/COVID19County_ViewLayer/FeatureServer/0"
  end

  def self.dashboard_url
    "https://www.arcgis.com/apps/opsdashboard/index.html#/ed483ecd702b4298ab01e8b9cafc8b83"
  end

  def self.county_keys
    # Example data:
    #
    # OBJECTID_1: 8,
    # OBJECTID: 8,
    # County: "Austin",
    # FIPS: "48015",
    # COUNTYFP10: "015",
    # Shape_Leng: 258336.897316,
    # Count_: 2,
    # LastUpdate: 1585586821356,
    # Shape__Area: 1693781284.64355,
    # Shape__Length: 258336.897316496,
    # Deaths: null
    {
      Positive_Cases: {
        name: "Positives (Counties)",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "Count_"
      },
      Deaths: {
        name: "Deaths (Counties)",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "Deaths"
      }
    }
  end
end
