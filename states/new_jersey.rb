require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class NewJersey < State
  DEPARTMENT = ""
  ACRONYM = "GDPH"

  def self.testing_gallery_url
    nil
  end

  def self.testing_gallery_url
    nil
  end

  def self.testing_feature_url
    "https://services7.arcgis.com/Z0rixLlManVefxqY/arcgis/rest/services/DailyCaseCounts/FeatureServer/0?f=json"
  end

  def self.testing_data_url
    "https://services7.arcgis.com/Z0rixLlManVefxqY/arcgis/rest/services/DailyCaseCounts/FeatureServer/0/query?where=1%3D1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=false&returnCentroid=false&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pjson&token="
  end

  def self.hospital_data_url
    "https://services7.arcgis.com/Z0rixLlManVefxqY/ArcGIS/rest/services/NJ_Beds_By_Counties/FeatureServer/0?f=json"
  end

  def self.dashboard_url
    "https://maps.arcgis.com/apps/opsdashboard/index.html#/ec4bffd48f7e495182226eee7962b422"
  end

  def self.relevant_keys
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
      new_positives: {
        name: "New Positives",
        description: "Tallied from individual county cases.",
        source: "NEW_CASES"
      },
      new_deaths: {
        name: "New Deaths",
        description: "Tallied from individual county cases.",
        source: "NEW_DEATHS"
      },
      positives: {
        name: "Positives",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "TOTAL_CASES"
      },
      deaths: {
        name: "Deaths",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "TOTAL_DEATHS"
      }

    }
  end
end
