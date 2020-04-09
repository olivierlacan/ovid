require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class Georgia < State
  DEPARTMENT = "Georgia Department of Health and Social Services"
  ACRONYM = "GDPH"

  def self.counties_feature_url
    "https://services1.arcgis.com/2iUE8l8JKrP2tygQ/ArcGIS/rest/services/COVID_19_Cases/FeatureServer/0"
  end

  def self.dashboard_url
    "https://augustagis.maps.arcgis.com/apps/opsdashboard/index.html#/4eec20925b6b4f338368df0ffcba472d"
  end

  def self.county_keys
    # Example data:
    #
    # OBJECTID: 46,
    # NAME: "Worth",
    # GlobalID: "4427d43b-ba56-410d-a125-6b31529954c1",
    # EditDate: 1585678609363,
    # COVID_Cases: 29,
    # COVID_Deaths: 1,
    # COVID_Recovered: null
    {
      positives: {
        name: "Positives",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "COVID_Cases"
      },
      deaths: {
        name: "Deaths",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "COVID_Deaths"
      },
      recovered: {
        name: "Recovered (Counties)",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "COVID_Recovered"
      }
    }
  end
end
