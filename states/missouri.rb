require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class Missouri < State
  DEPARTMENT = "Missouri Public Health Emergency Preparedness"
  ACRONYM = "MOPHEP"

  def self.state_name
    "Missouri"
  end

  def self.gallery_url
    "http://mophep.maps.arcgis.com/home/gallery.html"
  end

  def self.counties_feature_url
    "https://services6.arcgis.com/Bd4MACzvEukoZ9mR/arcgis/rest/services/lpha_boundry/FeatureServer/0"
  end

  def self.dashboard_url
    "https://experience.arcgis.com/experience/89062268ee6844fd8c19b18ace390917"
  end

  def self.county_keys
    {
      under20: {
        name: "Confirmed - Age - 0 to 19",
        source: "under20"
      },
      twenty1: {
        name: "Confirmed - Age - 20 to 24",
        source: "twenty1"
      },
      twenty: {
        name: "Confirmed - Age - 25 to 29",
        source: "twenty"
      },
      thirty1: {
        name: "Confirmed - Age - 30 to 34",
        source: "thirty1"
      },
      thirty: {
        name: "Confirmed - Age - 35 to 39",
        source: "thirty"
      },
      fourty1: {
        name: "Confirmed - Age - 40 to 44",
        source: "fourty1"
      },
      fourty: {
        name: "Confirmed - Age - 45 to 49",
        source: "fourty"
      },
      fifty1: {
        name: "Confirmed - Age - 50 to 54",
        source: "fifty1"
      },
      fifty: {
        name: "Confirmed - Age - 55 to 59",
        source: "fifty"
      },
      sixty1: {
        name: "Confirmed - Age - 60 to 64",
        source: "sixty1"
      },
      sixty: {
        name: "Confirmed - Age - 65 to 69",
        source: "Age_65_74"
      },
      seventy1: {
        name: "Confirmed - Age - 70 to 74",
        source: "seventy1"
      },
      seventy: {
        name: "Confirmed - Age - 75 to 79",
        source: "seventy"
      },
      eighty: {
        name: "Confirmed - Age - 80 and over",
        source: "eighty"
      },
      age_unknown: {
        name: "Confirmed - Age - Unknown",
        source: "Un_known"
      },
      confirmed_female: {
        name: "Confirmed - Female",
        source: "Women"
      },
      confirmed_male: {
        name: "Confirmed - Male",
        source: "Male"
      },
      confirmed_unknown_gender: {
        name: "Confirmed - Gender Unknown",
        source: "UnknownGender"
      },
      contact: {
        name: "Contact",
        source: "Contact"
      },
      contact_unknown: {
        name: "Contact - No Known Contact",
        source: "NoKnownContact"
      },
      travel: {
        name: "Travel",
        source: "Travel"
      },
      deaths: {
        name: "Deaths",
        highlight: true,
        source: "Deaths"
      },
      cases: {
        name: "Cases",
        highlight: true,
        source: "Cases"
      },
      SPHL: {
        name: "SPHL",
        highlight: true,
        description: "Cases tested at State Public Health Laboratory.",
        source: "SPHL"
      },
      OtherLabs: {
        name: "OtherLabs",
        description: "Cases tested at other labs",
        highlight: true,
        source: "OtherLabs"
      },
      Population: {
        name: "Population",
        source: "POP00"
      }
    }
  end
end
