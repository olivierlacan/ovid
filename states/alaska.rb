require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class Alaska < State
  DEPARTMENT = "Alaska Department of Health and Social Services"
  ACRONYM = "ADHSS"

  def self.testing_gallery_url
    nil
  end

  def self.counties_feature_url
    "https://services1.arcgis.com/WzFsmainVTuD5KML/ArcGIS/rest/services/Cases_current/FeatureServer/0"
  end

  def self.hospitals_feature_url
    "https://services1.arcgis.com/WzFsmainVTuD5KML/ArcGIS/rest/services/COVID_Hospital_Dataset_(prod)/FeatureServer/0"
  end

  def self.dashboard_url
    "https://coronavirus-response-alaska-dhss.hub.arcgis.com/"
  end

  def self.county_keys
    # name: Matanuska-Susitna Borough
    # GlobalID: 6f67b271-42f4-4f63-9259-f42484e17715
    # CreationDate: 3/17/2020 7:10:27 PM
    # Creator:  mack.wood_Alaska_DHSS
    # EditDate: 3/17/2020 7:10:27 PM
    # Editor: mack.wood_Alaska_DHSS
    # Shape__Area:  302045640682.781
    # Shape__Length:  2478217.29752402
    # name_1584379187045: Matanuska-Susitna Borough
    # reportdt:
    # confirmed:  4
    # recovered:  0
    # deaths: 0
    # active: 4
    # GlobalID_1584379187045: 0c8715b9-2f92-45c0-b518-2a828fb37e8e
    # tested: 0
    # CreationDate_1584379187045:
    # Creator_1584379187045:
    # EditDate_1584379187045:
    # Editor_1584379187045:
    # ObjectId:
    {
      confirmed: {
        name: "Confirmed",
        highlight: true
      },
      deaths: {
        name: "Deaths",
        highlight: true,
        source: "deaths"
      },
      active: {
        name: "Active",
        highlight: true,
        source: "active"
      },
      tested: {
        name: "Tested",
        source: "tested"
      },
      recovered: {
        name: "Recovered",
        source: "recovered"
      }
    }
  end

  def self.hospitals_keys
    # Example data:
    #
    # Region:  Anchorage
    # All_Beds: 1346
    # Inpatient_Beds: 1102
    # Inpatient_Occup:  635
    # Inpatient_Avail:  467
    # ICU_Beds: 121
    # ICU_Occup:  74
    # ICU_Avail:  47
    # Pos_COVID_PUI_Pending:  7
    # Vent_Cap: 205
    # Vent_Avail: 179
    # Vent_Occup: 26
    # FID:  1
    {
      All_Beds: {
        name: "All Beds",
        source: "All_Beds"
      },
      Inpatient_Beds: {
        name: "Inpatient Beds",
        source: "Inpatient_Beds"
      },
      Inpatient_Occup: {
        name: "Inpatient Beds - Occupied",
        source: "Inpatient_Occup"
      },
      Inpatient_Avail: {
        name: "Inpatient Beds - Available",
        source: "Inpatient_Avail"
      },
      ICU_Beds: {
        name: "ICU Beds",
        source: "ICU_Beds"
      },
      ICU_Occup: {
        name: "ICU Beds - Occupied",
        source: "ICU_Occup"
      },
      ICU_Avail: {
        name: "ICU Beds - Available",
        source: "ICU_Avail"
      },
      Pos_COVID_PUI_Pending: {
        name: "Positive COVID-19 positive patients pending",
        source: "Pos_COVID_PUI_Pending"
      },
      Vent_Cap: {
        name: "Ventilators - Capacity",
        source: "Vent_Cap"
      },
      Vent_Avail: {
        name: "Ventilators - Available",
        source: "Vent_Avail"
      },
      Vent_Occup: {
        name: "Ventilators - Occupied",
        source: "Vent_Occup"
      }
    }
  end
end
