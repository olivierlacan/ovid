# frozen_string_literal: true

require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class Texas < State
  DEPARTMENT = "Texas State Department of Health"
  ACRONYM = "TDSHS"

  def self.counties_feature_url
    "https://services5.arcgis.com/ACaLB9ifngzawspq/ArcGIS/rest/services/DSHS_COVID19_Cases_Service/FeatureServer/0"
  end

  def self.hospitals_feature_url
    "https://services5.arcgis.com/ACaLB9ifngzawspq/ArcGIS/rest/services/DSHS_COVID_Hospital_Data/FeatureServer/0"
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
        source: :Positive
      },
      Fatalities: {
        name: "Fatalities",
        highlight: true,
        source: :Fatalities
      },
      Recoveries: {
        name: "Recoveries",
        highlight: true,
        source: :Recoveries
      },
      Active: {
        name: "Active",
        highlight: true,
        source: :Active
      }
    }
  end

  def self.hospitals_keys
    # Example data:
    # OBJECTID: 1
    # TSA:  A
    # RAC:  Panhandle RAC
    # PopEst2020: 440127
    # TotalStaff: 1064
    # AvailHospi: 369
    # AvailICUBe: 29
    # AvailVenti: 117
    # COVIDPatie: 47
    # Shape__Area:  65076563229.2397
    # Shape__Length:  1138687.50123686

    {
      covid_19_patients: {
        name: "COVID-19 patients",
        description: "Lab Confirmed COVID-19 Patients currently in Texas hospitals.",
        source: :COVIDPatie
      },
      total_staffed_beds: {
        name: "Total Staffed Hospital Beds",
        source: :TotalStaff
      },
      available_beds: {
        name: "Available Hospital Beds",
        highlight: true,
        source: :AvailHospi
      },
      available_icu_bed: {
        name: "Available ICU beds",
        highlight: true,
        source: :AvailICUBe
      },
      available_vents: {
        name: "Available ventilators",
        highlight: true,
        source: :AvailVenti
      },
      population_estimate: {
        name: "2019 Population Estimate",
        source: :PopEst2020
      }
    }
  end
end
