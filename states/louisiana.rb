require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class Louisiana < State
  DEPARTMENT = "Georgia Department of Health and Social Services"
  ACRONYM = "LDH"

  def self.testing_gallery_url
    nil
  end

  def self.testing_gallery_url
    nil
  end

  def self.testing_feature_url
    "https://services5.arcgis.com/O5K6bb5dZVZcTo5M/arcgis/rest/services/Cases_by_Parish/FeatureServer/0?f=json"
  end

  def self.testing_data_url
    "https://services5.arcgis.com/O5K6bb5dZVZcTo5M/arcgis/rest/services/Cases_by_Parish/FeatureServer/0/query?where=1%3D1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=false&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pjson&token="
  end

  def self.dashboard_url
    "https://www.arcgis.com/apps/opsdashboard/index.html#/69b726e2b82e408f89c3a54f96e8f776"
  end

  def self.relevant_keys
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
        name: "Positives (Counties)",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "Cases"
      },
      deaths: {
        name: "Deaths (Counties)",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "Deaths"
      },
      commercial_tests: {
        name: "Tests - Commercial (Counties)",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "Commercial_Tests"
      },
      state_tests: {
        name: "Tests - State (Counties)",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "State_Tests"
      },
    }
  end
end
