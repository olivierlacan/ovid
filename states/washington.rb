require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class Washington < State
  DEPARTMENT = "Washington State Department of Health"
  ACRONYM = "WSDOH"

  def self.state_name
    "Washington"
  end

  def self.testing_gallery_url
    nil
  end

  def self.testing_gallery_url
    "https://wa-geoservices.maps.arcgis.com/home/gallery.html"
  end

  def self.testing_feature_url
    "https://services8.arcgis.com/rGGrs6HCnw87OFOT/arcgis/rest/services/CountyCases/FeatureServer/0?f=json"
  end

  def self.testing_data_url
    "https://services8.arcgis.com/rGGrs6HCnw87OFOT/arcgis/rest/services/CountyCases/FeatureServer/0/query?where=1%3D1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=false&returnCentroid=false&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=102100&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=true&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=0&resultRecordCount=50&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pjson&token="
  end

  def self.dashboard_url
    "https://www.arcgis.com/apps/MapSeries/index.html?appid=84b17c2a2af8487f97a244b6126834c2"
  end

  def self.relevant_keys
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
        name: "Positives (Counties)",
        description: "Tallied from individual county cases.",
        highlight: false,
        source: "CV_PositiveCases"
      },
      Deaths: {
        name: "Deaths (Counties)",
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
