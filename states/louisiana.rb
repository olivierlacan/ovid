require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class Louisiana < State
  DEPARTMENT = "Georgia Department of Health and Social Services"
  ACRONYM = "LDH"

  def self.counties_feature_url
    "https://services5.arcgis.com/O5K6bb5dZVZcTo5M/arcgis/rest/services/Cases_by_Parish/FeatureServer/0"
  end

  def self.dashboard_url
    "https://www.arcgis.com/apps/opsdashboard/index.html#/69b726e2b82e408f89c3a54f96e8f776"
  end

  def self.county_keys
    # Example data:
    #
    # OBJECTID: 8,
    # PFIPS: "22015",
    # Latitude: 32.67963,
    # Longitude: -93.6052,
    # LDHH: 7,
    # Parish: "Bossier",
    # Cases: 75,
    # Deaths: 1,
    # Commercial_Tests: 1212,
    # State_Tests: 27,
    # FID: 8
    {
      positives: {
        name: "Positives",
        highlight: true,
        source: "Cases"
      },
      deaths: {
        name: "Deaths",
        highlight: true,
        source: "Deaths"
      },
      commercial_tests: {
        name: "Tests - Commercial",
        highlight: true,
        source: "Commercial_Tests"
      },
      state_tests: {
        name: "Tests - State",
        highlight: true,
        source: "State_Tests"
      },
    }
  end
end
