# frozen_string_literal: true

require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class Utah < State
  DEPARTMENT = "Utah Department of Health"
  ACRONYM = "UDOH"

  def self.counties_feature_url
    "https://services6.arcgis.com/KaHXE9OkiB9e63uE/arcgis/rest/services/Utah_COVID19_Cases_by_Local_Health_Department_View/FeatureServer/0"
  end

  def self.dashboard_url
    "https://www.arcgis.com/apps/opsdashboard/index.html#/cf15d9e3af9c4d2b8b08c9d3ef59697e"
  end

  def self.county_keys
    # Example data:
    #
    # OBJECTID: 11,
    # DISTNAME: "Davis County",
    # ID_NUM: 3,
    # Shape__Area: 2890425964.70703,
    # Shape__Length: 277556.966450575,
    # COVID_Cases_Utah_Resident: 84,
    # COVID_Cases_Non_Utah_Resident: 0,
    # COVID_Cases_Total: 84
    #
    {
      Cases_Utah_Resident: {
        name: "Positives - Utah Resident",
        highlight: true,
        source: :COVID_Cases_Utah_Resident
      },
      Cases_Non_Utah_Resident: {
        name: "Positives - Non-Utah Resident",
        highlight: true,
        source: :COVID_Cases_Non_Utah_Resident
      },
      Cases_Total: {
        name: "Positives - Total",
        highlight: true,
        source: :COVID_Cases_Total
      }
    }
  end
end
