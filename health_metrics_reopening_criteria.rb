require "net/http"
require "json"
require "csv"
require "date"
require "time"

timestamp = DateTime.now.strftime("%Y-%m-%d_%Hh%Mm%Ss")


health_metics_uri = URI "https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/ArcGIS/rest/services/Metrics_All/FeatureServer/0/query?where=1%3D1&objectIds=&time=&resultType=standard&outFields=*&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnDistinctValues=false&cacheHint=false&orderByFields=Week_EndDate+ASC&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&sqlFormat=standard&f=json&token="
health_metrics_raw = Net::HTTP.get(health_metics_uri)
health_metrics_json = JSON.parse(health_metrics_raw)

# ID: Broward-02/23/2020
# Week_StartDate: 2/23/2020 12:00:00 AM
# County: Broward
# W_ILI:  0
# W_COVIDL: 0
# W_NegTests: 0
# W_PosTests: 0
# W_TTotal: 0
# W_PercPos:  0
# W_Positivity: 0
# W_Events: 17
# Week_EndDate: 2/29/2020 12:00:00 AM
# StartDate2: 2/23/2020 5:00:00 AM
# EndDate2: 2/29/2020 5:00:00 AM
# ObjectId: 1

def convert_date(timestamp)
  DateTime.strptime(timestamp.to_s, "%Q").to_date
end

first_date = convert_date(health_metrics_json["features"].first["attributes"]["Week_StartDate"])
last_date = convert_date(health_metrics_json["features"].last["attributes"]["Week_StartDate"])

dates = (first_date..last_date).to_a

rows = health_metrics_json["features"]

counties = rows.group_by { _1["attributes"]["County"] }
sorted_counties = counties.each_with_object([]) do |row, memo|
  memo << {
    county: row.first,
    weeks: row.last.sort_by { _1["attributes"]["Week_StartDate"] }.map { |dd|
      data = dd["attributes"].slice(
        "W_Deaths",
        "W_ILI",
        "W_COVIDL",
        "W_NegTests",
        "W_PosTests",
        "W_TTotal",
        "W_PercPos",
        "W_Events",
        "Week_StartDate",
        "Week_EndDate"
      )

      data["Week_StartDate"] = convert_date(data["Week_StartDate"]).iso8601
      data["Week_EndDate"] = convert_date(data["Week_EndDate"]).iso8601

      data
    }
  }
end

def percentage_change(current, previous)
  (current.fdiv(previous) * 100).ceil(2)
end

def delta(current, previous)
  current - previous
end

def movement(delta)
  if delta.positive?
    "Up (#{delta})"
  elsif delta.negative?
    "Down (#{delta})"
  else
    "Stable (#{delta})"
  end
end

reopening = sorted_counties.each_with_object([]) do |county, memo|
  weeks = county[:weeks]
  last_two_weeks = weeks.last(2).map do |week|
    previous = weeks[weeks.find_index(week) - 1]
    {
      Week_StartDate: week["Week_StartDate"],
      Comparison_Week_StartDate: previous["Week_StartDate"],
      ReOpeningCriteria: {
        SyndromicSurveillance: {
          W_ILI: {
            change: percentage_change(week["W_ILI"], previous["W_ILI"]),
            delta: delta(week["W_ILI"], previous["W_ILI"]),
            passing: delta(week["W_ILI"], previous["W_ILI"]).negative?,
            movement: movement(delta(week["W_ILI"], previous["W_ILI"]))
          },
          W_COVIDL: {
            change: percentage_change(week["W_COVIDL"], previous["W_COVIDL"]),
            delta: delta(week["W_COVIDL"], previous["W_COVIDL"]),
            passing: delta(week["W_COVIDL"], previous["W_COVIDL"]).negative?,
            movement: movement(delta(week["W_COVIDL"], previous["W_COVIDL"]))
          },
          W_Events: {
            change: percentage_change(week["W_Events"], previous["W_Events"]),
            delta: delta(week["W_Events"], previous["W_Events"]),
            passing: delta(week["W_Events"], previous["W_Events"]).negative?,
            movement: movement(delta(week["W_Events"], previous["W_Events"]))
          }
        },
        EpidemiologyOutbreakDecline: {
          W_PosTests: {
            change: percentage_change(week["W_PosTests"], previous["W_PosTests"]),
            delta: delta(week["W_PosTests"], previous["W_PosTests"]),
            passing: delta(week["W_PosTests"], previous["W_PosTests"]).negative?,
            movement: movement(delta(week["W_PosTests"], previous["W_PosTests"]))
          },
          W_PercPos: {
            change: percentage_change(week["W_PercPos"], previous["W_PercPos"]),
            delta: delta(week["W_PercPos"], previous["W_PercPos"]),
            passing: delta(week["W_PercPos"], previous["W_PercPos"]).negative?,
            movement: movement(delta(week["W_PercPos"], previous["W_PercPos"]))
          }
        },
        HealthcareCapacity: {
          W_TTotal: {
            change: percentage_change(week["W_TTotal"], previous["W_TTotal"]),
            delta: delta(week["W_TTotal"], previous["W_TTotal"]),
            passing: delta(week["W_TTotal"], previous["W_TTotal"]).positive?,
            movement: movement(delta(week["W_TTotal"], previous["W_TTotal"]))
          },
          W_NegTests: {
            change: percentage_change(week["W_NegTests"], previous["W_NegTests"]),
            delta: delta(week["W_NegTests"], previous["W_NegTests"]),
            passing: delta(week["W_NegTests"], previous["W_NegTests"]).positive?,
            movement: movement(delta(week["W_NegTests"], previous["W_NegTests"]))
          }
        }
      }
    }
  end

  memo << { county: county[:county], last_two_weeks: last_two_weeks }
end

require "oj"

File.open("exports/reopening_metrics_per_county.json", "wb") do |file|
  file << Oj.dump(reopening)
end

summary = reopening.each_with_object([]) do |county, memo|
  memo << {
    county: county[:county],
    weeks: [
      county[:last_two_weeks].each_with_object([]) do |week, memo|
        memo << {
          week_starting_in: week[:Week_StartDate],
          compared_to_week_starting_in: week[:Comparison_Week_StartDate],
          criteria: {
            SyndromicSurveillance: {
              InfluezaLikeIllnesses: {
                passing: week[:ReOpeningCriteria][:SyndromicSurveillance][:W_ILI][:passing],
                movement: week[:ReOpeningCriteria][:SyndromicSurveillance][:W_ILI][:movement]
              },
              CovidLikeIllnesses: {
                passing: week[:ReOpeningCriteria][:SyndromicSurveillance][:W_COVIDL][:passing],
                movement: week[:ReOpeningCriteria][:SyndromicSurveillance][:W_COVIDL][:movement]
              }
            },
            EpidemiologyOutbreakDecline: {
              WeeklyPositiveResidents: {
                passing: week[:ReOpeningCriteria][:EpidemiologyOutbreakDecline][:W_PosTests][:passing],
                movement: week[:ReOpeningCriteria][:EpidemiologyOutbreakDecline][:W_PosTests][:movement]
              },
              ResidentPositivity: {
                passing: week[:ReOpeningCriteria][:EpidemiologyOutbreakDecline][:W_PercPos][:passing],
                movement: week[:ReOpeningCriteria][:EpidemiologyOutbreakDecline][:W_PercPos][:movement]
              }
            },
            HealthcareCapacity: {
              TotalTests: {
                passing: week[:ReOpeningCriteria][:HealthcareCapacity][:W_TTotal][:passing],
                movement: week[:ReOpeningCriteria][:HealthcareCapacity][:W_TTotal][:movement]
              }
            }
          }
        }
      end
    ]
  }
end

File.open("exports/reopening_metrics_per_county_summary#{timestamp}.json", "wb") do |file|
  file << Oj.dump(summary)
end

def week_passing?(week)
  [
    week[:ReOpeningCriteria][:SyndromicSurveillance][:W_ILI][:passing] &&
    week[:ReOpeningCriteria][:SyndromicSurveillance][:W_COVIDL][:passing],
    week[:ReOpeningCriteria][:EpidemiologyOutbreakDecline][:W_PosTests][:passing] ||
    week[:ReOpeningCriteria][:EpidemiologyOutbreakDecline][:W_PercPos][:passing],
    week[:ReOpeningCriteria][:HealthcareCapacity][:W_TTotal][:passing]
  ].all?
end

counties_passing_one_of_the_last_two_weeks = reopening.select do |county|
  county[:last_two_weeks].one? { week_passing?(_1)}
end.map { _1[:county] }

counties_passing_none_of_last_two_weeks = reopening.select do |county|
  county[:last_two_weeks].none? { week_passing?(_1)}
end.map { _1[:county] }

counties_passing_all_of_last_two_weeks = reopening.select do |county|
  county[:last_two_weeks].all? { week_passing?(_1)}
end.map { _1[:county] }

high_level_report = {
  one_week_passing: reopening.select do |county|
    county[:last_two_weeks].one? { week_passing?(_1)}
  end.map { _1[:county] },
  no_week_passing: reopening.select do |county|
    county[:last_two_weeks].none? { week_passing?(_1)}
  end.map { _1[:county] },
  two_weeks_passing: reopening.select do |county|
    county[:last_two_weeks].all? { week_passing?(_1)}
  end.map { _1[:county] }
}

File.open("exports/reopening_per_county_lists.json", "wb") do |file|
  file << Oj.dump(high_level_report)
end
