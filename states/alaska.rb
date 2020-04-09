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

  def self.cases_feature_url
    "https://services1.arcgis.com/WzFsmainVTuD5KML/ArcGIS/rest/services/COVID_Cases_public/FeatureServer/0"
  end

  def self.dashboard_url
    "https://coronavirus-response-alaska-dhss.hub.arcgis.com/"
  end

  def self.case_keys
    {
      positives: {
        name: "Positives",
        count_of_total_records: true,
        highlight: true
      },
      deaths: {
        name: "Deaths",
        positive_value: "Y",
        highlight: true,
        source: "Deceased"
      },
      hospitalized: {
        name: "Hospitalized",
        positive_value: "Y",
        highlight: true,
        source: "Hospitalized"
      }
    }
  end
end
