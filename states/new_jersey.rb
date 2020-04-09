require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class NewJersey < State
  DEPARTMENT = ""
  ACRONYM = "GDPH"

  def self.counties_feature_url
    "https://services7.arcgis.com/Z0rixLlManVefxqY/arcgis/rest/services/DailyCaseCounts/FeatureServer/0"
  end

  def self.dashboard_url
    "https://maps.arcgis.com/apps/opsdashboard/index.html#/ec4bffd48f7e495182226eee7962b422"
  end

  def self.county_keys
    # Example data:
    #
    # OBJECTID_1: 9,
    # OBJECTID: 9,
    # COUNTY: "HUDSON",
    # COUNTY_LAB: "Hudson County",
    # Region: "North",
    # TOTAL_CASES: 2270,
    # DEATHS: 44,
    # Shape__Area: 1436707422.2616,
    # Shape__Length: 381356.570662874
    {
      positives: {
        name: "Positives (Counties)",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "TOTAL_CASES"
      },
      deaths: {
        name: "Deaths (Counties)",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "DEATHS"
      }
    }
  end
end
