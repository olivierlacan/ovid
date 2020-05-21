require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class Texas < State
  DEPARTMENT = "Texas State Department of Health"
  ACRONYM = "TDSHS"

  def self.counties_feature_url
    "https://services5.arcgis.com/ACaLB9ifngzawspq/ArcGIS/rest/services/DSHS_COVID19_Service/FeatureServer/0"
  end

  def self.hospitals_feature_url
    "https://services1.arcgis.com/d9sLvPecHnb8pMfE/arcgis/rest/services/TSA_BedAvailability_ViewTest/FeatureServer/0"
  end

  def self.dashboard_url
    "https://www.arcgis.com/apps/opsdashboard/index.html#/ed483ecd702b4298ab01e8b9cafc8b83"
  end

  def self.county_keys
    # Example data:
    #
    # OBJECTID: 2
    # County: Andrews
    # Positive: 22
    # Fatalities: 0
    # Recoveries: 21
    # Active: 1
    # Shape__Area:  3872439726.24023
    # Shape__Length:  256968.659368344

    {
      Positive: {
        name: "Positives",
        highlight: true,
        source: "Positive"
      },
      Fatalities: {
        name: "Fatalities",
        highlight: true,
        source: "Fatalities"
      },
      Recoveries: {
        name: "Recoveries",
        highlight: true,
        source: "Recoveries"
      },
      Active: {
        name: "Active",
        highlight: true,
        source: "Active"
      }
    }
  end

  def self.hospitals_keys
    # Example data:
    #
    # OBJECTID_1: 5
    # TSA:  E
    # RAC:  North Central Texas
    # PHR8: 2/3
    # Sum_Adult_ICU:  721
    # Sum_Total_Beds: 5091
    # Sum_Total_Vents_Avail:  1371
    # Sum_Total_Lab_COVID:  477
    # Sum_Total_Hosp_Beds:  14021
    # Sum_POP2019EST: 7888098
    {
      sum_adult_icu: {
        name: "Available ICU beds",
        highlight: true,
        source: "Sum_Adult_ICU"
      },
      sum_total_beds: {
        name: "Available hospital beds",
        highlight: true,
        source: "Sum_Total_Beds"
      },
      sum_vents_available: {
        name: "Available ventilators",
        highlight: true,
        source: "Sum_Total_Vents_Avail"
      },
      sum_total_hospitalized_positives: {
        name: "Hospitalized Positive Patients",
        description: "Lab-Confirmed COVID-19 Patients Currently In Hospital",
        highlight: true,
        source: "Sum_Total_Lab_COVID"
      },
      sum_total_hospital_beds: {
        name: "Staffed Hospital Beds",
        source: "Sum_Total_Hosp_Beds"
      },
      population_estimate: {
        name: "2019 Population Estimate",
        source: "Sum_POP2019EST"
      }
    }
  end
end
