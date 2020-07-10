# frozen_string_literal: true

require "net/http"
require "json"
require "csv"
require "date"

county_data_uri = URI "https://services1.arcgis.com/P5Mv5GY5S66M8Z1Q/arcgis/rest/services/NCOV_Cases_California_Counties/FeatureServer/0/query?where=1%3D1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=false&returnCentroid=false&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pjson&token="
county_data_raw = Net::HTTP.get(county_data_uri)
county_data_json = JSON.parse(county_data_raw)

cases = county_data_json["features"]
# {
# OBJECTID: 4,
# COUNTY_NAME: "San Benito",
# FIPS: "06069",
# POPULATION: 59354,
# POP_SQMI: 42.7,
# Active: 11,
# Deaths: 1,
# Recovered: 2,
# Cumulative: 14,
# Shape__Area: 5599403013.33594,
# Shape__Length: 458142.190640416
# }

testing_keys = %w[
  cumulative
  deaths
  population
  active
  recovered
]

testing_totals = testing_keys.each_with_object({}) do |key, store|
  store[key] = 0
end

testing_totals["counties"] = []

cases.each_with_object(testing_totals) do |test, store|
  a = test["attributes"]

  store["counties"] << a["COUNTY_NAME"]
  store["cumulative"] += a["Cumulative"]
  store["deaths"] += a["Deaths"]
  store["population"] += a["POPULATION"]
  store["active"] += a["Active"]
  store["recovered"] += a["Recovered"]
end

testing_totals["counties_count"] = testing_totals["counties"].count
testing_totals.delete("counties")

pp testing_totals
