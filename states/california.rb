require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class California < State
  DEPARTMENT = "Loma Linda University Health"
  ACRONYM = "LLUH"

  def self.testing_gallery_url
    nil
  end

  def self.testing_gallery_url
    "https://covid19-lluh.hub.arcgis.com/"
  end

  def self.testing_feature_url
    "https://services7.arcgis.com/aFfS9FqkIRSo0Ceu/ArcGIS/rest/services/COVID_19_Daily_Cases_California_Counties_View_Only/FeatureServer/0?f=json"
  end

  def self.testing_data_url
    "https://services7.arcgis.com/aFfS9FqkIRSo0Ceu/ArcGIS/rest/services/COVID_19_Daily_Cases_California_Counties_View_Only/FeatureServer/0/query?where=1%3D1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=false&returnCentroid=false&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pjson&token="
  end

  def self.dashboard_url
    "https://lluh.maps.arcgis.com/apps/opsdashboard/index.html#/0a31ad9308574e93b18980acae25f68a"
  end

  def self.relevant_keys
    # Example data:
    #
    # OBJECTID_1: 3,
    # OBJECTID: 40,
    # NAME: "San Diego",
    # STATE_NAME: "California",
    # Confirmed_Cases: 734,
    # Confirmed_Deaths: 9,
    # Recovered: null,
    # Last_Updated: 1585638000000,
    # Source: "San Diego County.gov",
    # Website: "https://www.sandiegocounty.gov/content/sdc/hhsa/programs/phs/community_epidemiology/dc/2019-nCoV/status.html",
    # New_Cases: 131,
    # New_Deaths: 2,
    # Label_Name: null,
    # GlobalID: "87467ef7-706d-40d9-951e-d21832c37f86",
    # Shape__Area: 15655800652.0547,
    # Shape__Length: 772836.486030842,
    # CreationDate: 1584496110481,
    # Creator: "HSACadmin",
    # EditDate: 1585765065379,
    # Editor: "jdunlap_hsac",
    # Source_Update: "Daily",
    # Age_Group_0_17: null,
    # Age_Group_18_40: null,
    # Age_Group_41_65: null,
    # Age_Group_Over_65: null,
    # Investigated_Cases: null,
    # Hospitalized: null

    {
      Confirmed_Cases: {
        name: "Positives (Counties)",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "Confirmed_Cases"
      },
      Deaths: {
        name: "Deaths (Counties)",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "Confirmed_Deaths"
      },
      Recovered: {
        name: "Recovered (Counties)",
        description: "Tallied from individual county cases.",
        highlight: false,
        source: "Recovered"
      },
      New_Cases: {
        name: "New Positives (Counties)",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "New_Cases"
      },
      New_Deaths: {
        name: "New Deaths (Counties)",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "New_Deaths"
      },
      Hospitalized: {
        name: "Hospitalized (Counties)",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "Hospitalized"
      }
    }
  end
end
