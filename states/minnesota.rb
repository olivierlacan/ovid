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
    "https://services2.arcgis.com/V12PKGiMAH7dktkU/arcgis/rest/services/PositiveCountyCount/FeatureServer/0/query?where=1%3D1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=false&returnCentroid=false&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pjson&token="
  end

  def self.dashboard_url
    "https://mndps.maps.arcgis.com/apps/opsdashboard/index.html#/f28f84968c1148129932c3bebb1d3a1a"
  end

  def self.aggregate_feature_url
    "https://services2.arcgis.com/V12PKGiMAH7dktkU/arcgis/rest/services/MyMapService/FeatureServer/0/?f=json"
  end

  def self.aggregate_data_url
    "https://services2.arcgis.com/V12PKGiMAH7dktkU/arcgis/rest/services/MyMapService/FeatureServer/0/query?where=1%3D1&objectIds=&time=&resultType=none&outFields=*&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&sqlFormat=none&f=pjson&token="
  end

  def self.aggregate_keys
    # OBJECTID: 1,
    # Date: "Date: 04/03/2020",
    # Time: "Time: 4:00pm",
    # TotalCases: 865,
    # RlsdFrmIsol: 440,
    # AgeRng: "0.4 - 104 years",
    # MedAge: "48 years",
    # Male: 427,
    # Female: 438,
    # SexMsng: 0,
    # RaceWht: 641,
    # RaceBlk: 49,
    # RaceAsnPacIsld: 31,
    # RaceAmerIndAlaNativ: 6,
    # RaceOther: 24,
    # RaceUnk: 35,
    # EthnHisp: 39,
    # EthnNonHisp: 666,
    # EthnUnk: 160,
    # EvrHospYes: 111,
    # EvrHospNo: 606,
    # EvrHospMisng: 79,
    # EvrICUYes: 69,
    # OutcmDied: 24,
    # ExpsrCrzShp: 26,
    # ExpsrIntrntnl: 112,
    # ExpsrLklyExpsr: 191,
    # ExpsrAnthrState: 158,
    # ExpsrInMN: 275,
    # ExpsrMsng: 103,
    # TstLabMDH: 316,
    # TstLabMayo: 384,
    # TstLabARUP: 13,
    # TstLabQwest: 48,
    # TstLabOthr: 101,
    # TstLabMsng: 3,
    # HlthCarWrker: 252,
    # SchlChldorEmp: 35,
    # ResPriv: 696,
    # ResLTCF: 26,
    # ResLngTrm: 1,
    # ResAssLvg: 15,
    # ResHmlShelt: 1,
    # ResJail: 7,
    # ResCollDrm: 0,
    # ResOther: 10,
    # ResMsng: 109,
    # GlobalID: "dfb4650e-8629-4b9e-a2ab-8f4477f4b495"
    {
      ethnicity_white: {
        name: "Ethnicity - White",
        description: "Aggregated report (not from individual case data)",
        source: "RaceWht"
      },
      ethnicity_black: {
        name: "Ethnicity - Black",
        description: "Aggregated report (not from individual case data)",
        source: "RaceBlk"
      },
      ethnicity_asian: {
        name: "Ethnicity - Asian Pacific Islander",
        description: "Aggregated report (not from individual case data)",
        source: "RaceAsnPacIsld"
      },
      ethnicity_native: {
        name: "Ethnicity - American Native",
        description: "Aggregated report (not from individual case data)",
        source: "RaceAmerIndAlaNativ"
      },
      ethnicity_unknown: {
        name: "Ethnicity - Unknown",
        description: "Aggregated report (not from individual case data)",
        source: "RaceUnk"
      },
      ethnicity_other: {
        name: "Ethnicity - Other",
        description: "Aggregated report (not from individual case data)",
        source: "RaceOther"
      }
    }
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
        source: "MLMIS_CTY"
      }
    }
  end
end
