require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class Georgia < State
  DEPARTMENT = "Georgia Department of Health and Social Services"
  ACRONYM = "GDPH"

  def self.testing_gallery_url
    nil
  end

  def self.testing_gallery_url
    nil
  end

  def self.testing_feature_url
    "https://services1.arcgis.com/2iUE8l8JKrP2tygQ/arcgis/rest/services/COVID19_County_Archive/FeatureServer/0?f=json"
  end

  def self.testing_data_url
    "https://services1.arcgis.com/2iUE8l8JKrP2tygQ/arcgis/rest/services/COVID19_County_Archive/FeatureServer/0/query?where=1%3D1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=false&returnCentroid=false&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=102100&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=true&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=0&resultRecordCount=50&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pjson&token="
  end

  def self.dashboard_url
    "https://augustagis.maps.arcgis.com/apps/opsdashboard/index.html#/4eec20925b6b4f338368df0ffcba472d"
  end

  def self.relevant_keys
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
        name: "Positives (Counties)",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "COVID_Cases"
      },
      deaths: {
        name: "Deaths (Counties)",
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
