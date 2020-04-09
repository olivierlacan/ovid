require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class Minnesota < State
  DEPARTMENT = ""
  ACRONYM = "GDPH"

  def self.counties_feature_url
    "https://services2.arcgis.com/V12PKGiMAH7dktkU/arcgis/rest/services/PositiveCountyCount/FeatureServer/0"
  end

  def self.dashboard_url
    "https://mndps.maps.arcgis.com/apps/opsdashboard/index.html#/f28f84968c1148129932c3bebb1d3a1a"
  end

  def self.totals_feature_url
    "https://services2.arcgis.com/V12PKGiMAH7dktkU/arcgis/rest/services/MyMapService/FeatureServer/0"
  end

  def self.totals_keys
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
      positives: {
        name: "Total Cases",
        description: "Positive cases from aggregated report (not from individual case data)",
        highlight: true,
total: true,
        source: "TotalCases"
      },
      deaths: {
        name: "Deaths",
        description: "Deaths from aggregated report (not from individual case data)",
        highlight: true,
        total: true,
        source: "OutcmDied"
      },
      released_from_isolation: {
        name: "Released from Isolation",
        total: true,
        source: "RlsdFrmIsol"
      },
      age_range: {
        name: "Age Range",
        total: true,
        source: "AgeRng"
      },
      median_age: {
        name: "Median Age",
        total: true,
        source: "MedAge"
      },
      ever_hospitalized_yes: {
        name: "Ever Hospitalized Yes",
        highlight: true,
        total: true,
        source: "EvrHospYes"
      },
      ever_hospitalized_no: {
        name: "Ever Hospitalized No",
        total: true,
        source: "EvrHospNo"
      },
      ever_hospitalized_missing: {
        name: "Ever Hospitalized Missing",
        total: true,
        source: "EvrHospMisng"
      },
      ever_icu_yes: {
        name: "Ever ICU Yes",
        highlight: true,
        total: true,
        source: "EvrICUYes"
      },
      residence_private: {
        name: "Residence - Private",
        total: true,
        source: "ResPriv"
      },
      residence_jail: {
        name: "Residence - Jail/Prison",
        total: true,
        source: "ResJail"
      },
      residence_college_dorm: {
        name: "Residence - College Dorm",
        total: true,
        source: "ResCollDrm"
      },
      residence_assisted: {
        name: "Residence - Assisted Living",
        total: true,
        source: "ResAssLvg"
      },
      residence_homeless_shelter: {
        name: "Residence - Homeless Shelter",
        total: true,
        source: "ResHmlShelt"
      },
      residence_long_time_care_facility: {
        name: "Residence - Long Time Care Facility",
        total: true,
        source: "ResLTCF"
      },
      residence_long_time_acute_care: {
        name: "Residence - Long Term Acute Care",
        total: true,
        source: "ResLngTrm"
      },
      residence_other: {
        name: "Residence - Other",
        total: true,
        source: "ResOther"
      },
      residence_missing: {
        name: "Residence - Missing",
        total: true,
        source: "ResMsng"
      },
      healthcare_worker: {
        name: "Healthcare Worker",
        total: true,
        source: "HlthCarWrker"
      },
      school_children_or_employee: {
        name: "School Children or Employee",
        total: true,
        source: "SchlChldorEmp"
      },
      exposure_cruise_ship: {
        name: "Exposure - Cruise Ship",
        total: true,
        source: "ExpsrCrzShp"
      },
      exposure_international_travel: {
        name: "Exposure - International Travel",
        total: true,
        source: "ExpsrIntrntnl"
      },
      exposure_likely: {
        name: "Exposure - Likely",
        total: true,
        source: "ExpsrLklyExpsr"
      },
      exposure_another_state: {
        name: "Exposure - Another State",
        total: true,
        source: "ExpsrAnthrState"
      },
      exposure_in_minnesota: {
        name: "Exposure - Minnesota Community Spread",
        total: true,
        source: "ExpsrInMN"
      },
      exposure_missing: {
        name: "Exposure - Missing",
        total: true,
        source: "ExpsrMsng"
      },
      male: {
        name: "Male",
        total: true,
        source: "Male"
      },
      female: {
        name: "Female",
        total: true,
        source: "Female"
      },
      sex_missing: {
        name: "Sex Missing",
        total: true,
        source: "SexMsng"
      },
      race_white: {
        name: "Race - White",
        total: true,
        source: "RaceWht"
      },
      race_black: {
        name: "Race - Black",
        total: true,
        source: "RaceBlk"
      },
      ethnicity_hispanic: {
        name: "Ethnicity - Hispanic",
        total: true,
        source: "EthnHisp"
      },
      ethnicity_non_hispanic: {
        name: "Ethnicity - Non-Hispanic",
        total: true,
        source: "EthnNonHisp"
      },
      race_asian: {
        name: "Race - Asian Pacific Islander",
        total: true,
        source: "RaceAsnPacIsld"
      },
      race_native: {
        name: "Race - American Native",
        total: true,
        source: "RaceAmerIndAlaNativ"
      },
      race_unknown: {
        name: "Race - Unknown",
        total: true,
        source: "RaceUnk"
      },
      ethnicity_unknown: {
        name: "Ethnicity - Unknown",
        total: true,
        source: "EthnUnk"
      },
      race_other: {
        name: "Race - Other",
        total: true,
        source: "RaceOther"
      },
      test_lab_mdh: {
        name: "Test Lab - Minnesota Department of Health",
        total: true,
        source: "TstLabMDH"
      },
      test_lab_mayo: {
        name: "Test Lab - Mayo Clinic",
        total: true,
        source: "TstLabMayo"
      },
      test_lab_arup: {
        name: "Test Lab - ARUP",
        total: true,
        source: "TstLabARUP"
      },
      test_lab_qwest: {
        name: "Test Lab - Qwest",
        total: true,
        source: "TstLabQwest"
      },
      test_lab_other: {
        name: "Test Lab - Other",
        total: true,
        source: "TstLabOthr"
      },
      test_lab_missing: {
        name: "Test Lab - Missing",
        total: true,
        source: "TstLabMsng"
      }
    }
  end

  def self.county_keys
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
        name: "Positives",
        highlight: true,
        source: "MLMIS_CTY"
      }
    }
  end
end
