# frozen_string_literal: true

require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class Louisiana < State
  DEPARTMENT = "Georgia Department of Health and Social Services"
  ACRONYM = "LDH"

  def self.counties_feature_url
    "https://services5.arcgis.com/O5K6bb5dZVZcTo5M/ArcGIS/rest/services/Cases_and_Deaths_by_Race_by_Parish/FeatureServer/0"
  end

  def self.dashboard_url
    "https://www.arcgis.com/apps/opsdashboard/index.html#/69b726e2b82e408f89c3a54f96e8f776"
  end

  def self.county_keys
    # Example data:
    # OBJECTID: 50
    # PFIPS:  22095
    # Latitude: 30.0771
    # Longitude:  -90.5468
    # LDHH: 3
    # Parish: St. John the Baptist
    # Deaths_Black: 48
    # Deaths_White: 39
    # Deaths_Other: 0
    # Deaths_Unknown: 0
    # Cases_Black:  677
    # Cases_White:  214
    # Cases_Other:  40
    # Cases_Unknown:  81
    # Black_2018pop:  24963
    # White_2018pop:  16854
    # Other_2018pop:  1367
    # FID:  49
    {
      cases_black: {
        name: "Cases - Black",
        highlight: true,
        source: :Cases_Black
      },
      cases_white: {
        name: "Cases - White",
        highlight: true,
        source: :Cases_White
      },
      cases_other: {
        name: "Cases - Other",
        source: :Cases_Other
      },
      cases_unknown: {
        name: "Cases - Unknown",
        highlight: true,
        source: :Cases_Unknown
      },
      deaths_black: {
        name: "Deaths - Black",
        highlight: true,
        source: :Deaths_Black
      },
      deaths_white: {
        name: "Deaths - White",
        highlight: true,
        source: :Deaths_White
      },
      deaths_other: {
        name: "Deaths - Other",
        source: :Deaths_Other
      },
      deaths_unknown: {
        name: "Deaths - Unknown",
        highlight: true,
        source: :Deaths_Unknown
      },
      population_black: {
        name: "Population - Black",
        highlight: true,
        source: :Black_2018pop
      },
      population_white: {
        name: "Population - White",
        highlight: true,
        source: :White_2018pop
      },
      population_other: {
        name: "Population - Other",
        source: :Other_2018pop
      },
    }
  end
end
