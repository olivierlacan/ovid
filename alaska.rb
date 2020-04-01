require "date"
require "time"
require "net/http"
require "json"

require "./state"

class Alaska < State
  DEPARTMENT = "Alaska Department of Health and Social Services"
  ACRONYM = "ADHSS"

  def self.testing_gallery_url
    nil
  end

  def self.testing_gallery_url
    nil
  end

  def self.testing_feature_url
    "https://services1.arcgis.com/WzFsmainVTuD5KML/arcgis/rest/services/Cases_current/FeatureServer/0?f=json"
  end

  def self.testing_data_url
    "https://services1.arcgis.com/WzFsmainVTuD5KML/arcgis/rest/services/Cases_current/FeatureServer/0/query?where=1%3D1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=false&returnCentroid=false&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=102100&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=true&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=0&resultRecordCount=50&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pjson&token="
  end

  def self.dashboard_url
    "https://coronavirus-response-alaska-dhss.hub.arcgis.com/"
  end

  def self.relevant_keys
    # Example data:
    #
    # name: "Fairbanks North Star Borough",
    # GlobalID: "e46471b0-11d5-40c1-87f4-6a864f2fcbf9",
    # CreationDate: 1584472227550,
    # Creator: "mack.wood_Alaska_DHSS",
    # EditDate: 1584472227550,
    # Editor: "mack.wood_Alaska_DHSS",
    # Shape__Area: 105839847596.594,
    # Shape__Length: 1883222.38776572,
    # name_1584379187045: "Fairbanks North Star Borough",
    # reportdt: null,
    # confirmed: 35,
    # recovered: 0,
    # deaths: 0,
    # active: 35,
    # GlobalID_1584379187045: "dd09f09b-2d11-40d4-968a-2f03b4457584",
    # tested: 0,
    # CreationDate_1584379187045: null,
    # Creator_1584379187045: null,
    # EditDate_1584379187045: null,
    # Editor_1584379187045: null,
    # ObjectId: 6
    {
      confirmed: {
        name: "Positives (Boroughs)",
        description: "Tallied from individual borough cases.",
        highlight: true,
        source: "confirmed"
      },
      deaths: {
        name: "Deaths (Boroughs)",
        description: "Tallied from individual borough cases.",
        highlight: true,
        source: "deaths"
      },
      tested: {
        name: "Tested (Boroughs)",
        description: "Tallied from individual borough cases.",
        highlight: true,
        source: "tested"
      }
    }
  end
end
