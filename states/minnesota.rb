require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class Minnesota < State
  DEPARTMENT = ""
  ACRONYM = "GDPH"

  def self.testing_gallery_url
    nil
  end

  def self.testing_gallery_url
    nil
  end

  def self.testing_feature_url
    "https://services2.arcgis.com/V12PKGiMAH7dktkU/arcgis/rest/services/PositiveCountyCount/FeatureServer/0?f=json"
  end

  def self.testing_data_url
    "https://services2.arcgis.com/V12PKGiMAH7dktkU/arcgis/rest/services/PositiveCountyCount/FeatureServer/0//query?where=1%3D1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=false&returnCentroid=false&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pjson&token="
  end

  def self.dashboard_url
    "https://mndps.maps.arcgis.com/apps/opsdashboard/index.html#/f28f84968c1148129932c3bebb1d3a1a"
  end

  def self.relevant_keys
    # Example data:
    #
    # OBJECTID_1: 11,
    # OBJECTID: 11,
    # AREA: 5927258624,
    # PERIMETER: 415164.625,
    # MN_CTYCB_: 12,
    # MN_CTYCB_I: 10,
    # FIPS_CTY: 75,
    # MLMIS_CTY: 0,
    # NAME_4CHAR: "LAKE",
    # NAME_LOWER: "Lake",
    # NAME_UPPER: "LAKE",
    # Shape_Leng: 415164.629016,
    # MnSvcCoope: "Northeast Service Cooperative",
    # HSEMRegion: "2",
    # PositiveCo: 0,
    # GlobalID: "5238fffd-898b-49c3-b998-24addc7a8354",
    # Shape__Area: 5927258861.48438,
    # Shape__Length: 415164.629016426
    {
      positives: {
        name: "Positives (Counties)",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "PositiveCo"
      }
    }
  end
end
