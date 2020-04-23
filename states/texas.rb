require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class Texas < State
  DEPARTMENT = "Texas State Department of Health"
  ACRONYM = "TDSHS"

  def self.counties_feature_url
    "https://services5.arcgis.com/ACaLB9ifngzawspq/arcgis/rest/services/COVID19County_ViewLayer/FeatureServer/0"
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
    # OBJECTID_1: 8,
    # OBJECTID: 8,
    # County: "Austin",
    # FIPS: "48015",
    # COUNTYFP10: "015",
    # Shape_Leng: 258336.897316,
    # Count_: 2,
    # LastUpdate: 1585586821356,
    # Shape__Area: 1693781284.64355,
    # Shape__Length: 258336.897316496,
    # Deaths: null
    {
      Positive_Cases: {
        name: "Positives (Counties)",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "Count_"
      },
      Deaths: {
        name: "Deaths (Counties)",
        description: "Tallied from individual county cases.",
        highlight: true,
        source: "Deaths"
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
