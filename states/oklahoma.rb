require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class Oklahoma < State
  DEPARTMENT = ""
  ACRONYM = "OSDH"

  def self.counties_feature_url
    "https://services6.arcgis.com/p971EoPdZ41QwRAN/ArcGIS/rest/services/Oklahoma_State_COVID_19_Data/FeatureServer/0"
  end

  def self.dashboard_url
    "https://www.arcgis.com/apps/opsdashboard/index.html#/2b237cccffcb47a899adc59e7e00c7c2"
  end

  def self.county_keys
    # Example data:
    #
    # OBJECTID:	1
    # Name_1:	Beaver
    # County_1:	Beaver
    # Case_Week_Chng:	0
    # Death_Week_Chng:	0
    # Recov_Week_Chng:	0
    # Date_Curr:	6/24/2020 12:00:00 AM
    # Case_Curr:	30
    # Death_Curr:	0
    # Recov_Curr:	30
    # Case_Chng:	0
    # Death_Chng:	0
    # Recov_Chng:	0
    # Avg_Case_Chng_Curr:	0
    # Avg_Recov_Chng_Curr:	0
    # Case_1D_Date:	6/23/2020 12:00:00 AM
    # Case_1D_Prev:	30
    # Death_1D_Prev:	0
    # Recov_1D_Prev:	30
    # Case_1D_Chng:	0
    # Death_1D_Prev_Chng:	0
    # Recov_1D_Prev_Chng:	0
    # Avg_Case_1D_Prev:	0
    # Avg_Recov_1D_Prev_Chng:	0
    # Case_2D_Date:	6/22/2020 12:00:00 AM
    # Case_2D_Prev:	30
    # Death_2D_Prev:	0
    # Recov_2D_Prev:	30
    # Case_2D_Chng:	0
    # Death_2D_Prev_Chng:	0
    # Recov_2D_Prev_Chng:	0
    # Avg_Case_2D_Prev:	0
    # Avg_Recov_2D_Prev_Chng:	0
    # Case_3D_Date:	6/21/2020 12:00:00 AM
    # Case_3D_Prev:	30
    # Death_3D_Prev:	0
    # Recov_3D_Prev:	30
    # Case_3D_Chng:	0
    # Death_3D_Prev_Chng:	0
    # Recov_3D_Prev_Chng:	0
    # Avg_Case_3D_Prev:	0
    # Avg_Recov_3D_Prev_Chng:	1
    # Case_4D_Date:	6/20/2020 12:00:00 AM
    # Case_4D_Prev:	30
    # Death_4D_Prev:	0
    # Recov_4D_Prev:	30
    # Case_4D_Chng:	0
    # Death_4D_Prev_Chng:	0
    # Recov_4D_Prev_Chng:	0
    # Avg_Case_4D_Prev:	0
    # Avg_Recov_4D_Prev_Chng:	1
    # Case_5D_Date:	6/19/2020 12:00:00 AM
    # Case_5D_Prev:	30
    # Death_5D_Prev:	0
    # Recov_5D_Prev:	30
    # Case_5D_Chng:	0
    # Death_5D_Prev_Chng:	0
    # Recov_5D_Prev_Chng:	0
    # Avg_Case_5D_Prev:	0
    # Avg_Recov_5D_Prev_Chng:	1
    # Case_6D_Date:	6/18/2020 12:00:00 AM
    # Case_6D_Prev:	30
    # Death_6D_Prev:	0
    # Recov_6D_Prev:	30
    # Case_6D_Chng:	0
    # Death_6D_Prev_Chng:	0
    # Recov_6D_Prev_Chng:	0
    # Avg_Case_6D_Prev:	0
    # Avg_Recov_6D_Prev_Chng:	1
    # Case_7D_Date:	6/17/2020 12:00:00 AM
    # Case_7D_Prev:	30
    # Death_7D_Prev:	0
    # Recov_7D_Prev:	30
    # Case_7D_Chng:	0
    # Death_7D_Prev_Chng:	0
    # Recov_7D_Prev_Chng:	1
    # Avg_Case_7D_Prev:	0
    # Avg_Recov_7D_Prev_Chng:	1
    {
      positives: {
        name: "Positives",
        highlight: true,
        source: "Case_Curr"
      },
      deaths: {
        name: "Deaths",
        highlight: true,
        source: "Death_Curr"
      },
      recovered: {
        name: "Recovered",
        source: "Recov_Curr"
      },
      new_positives: {
        name: "New Positives (Prior Day)",
        highlight: true,
        source: "Case_1D_Prev"
      },
      new_deaths: {
        name: "New Deaths (Prior Day)",
        highlight: true,
        source: "Death_1D_Prev"
      },
      new_recovered: {
        name: "New Recovered (Prior Day)",
        source: "Recov_1D_Prev"
      }
    }
  end
end
