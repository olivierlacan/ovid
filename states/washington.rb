require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class Washington < State
  DEPARTMENT = "Washington State Department of Health"
  ACRONYM = "WSDOH"

  def self.testing_gallery_url
    "https://wa-geoservices.maps.arcgis.com/home/gallery.html"
  end

  def self.counties_feature_url
    "https://services8.arcgis.com/rGGrs6HCnw87OFOT/arcgis/rest/services/CountyCases/FeatureServer/0"
  end

  def self.dashboard_url
    "https://www.arcgis.com/apps/MapSeries/index.html?appid=84b17c2a2af8487f97a244b6126834c2"
  end

  def self.county_keys
    # Example data:
    #
    # OBJECTID: 5,
    # CNTY_NAME: "Ferry",
    # CV_PositiveCases: 1,
    # CV_Comment: "Under Governor's Stay Home, Stay Healthy order",
    # CV_Deaths: 0,
    # CV_SuspectedCases: -1,
    # CV_Updated: 1585551359000,
    # CV_State_Cases: 4896,
    # CV_State_Unassigned: 387,
    # CV_State_Deaths: 195,
    # Shape__Area: 13290534242.6094,
    # Shape__Length: 594518.402940987
    {
      Positive_Cases: {
        name: "County Positives",
        description: "Tallied from individual county cases.",
        highlight: false,
        source: "CV_PositiveCases"
      },
      Deaths: {
        name: "County Deaths",
        description: "Tallied from individual county cases.",
        highlight: false,
        source: "CV_Deaths"
      },
      statewide_cases: {
        name: "Statewide Positives",
        highlight: true,
        source: "CV_State_Cases",
        total: true
      },
      statewide_deaths: {
        name: "Statewide Deaths",
        highlight: true,
        source: "CV_State_Deaths",
        total: true
      }
    }
  end
end
