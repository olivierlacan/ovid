# frozen_string_literal: true

require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class Florida < State
  DEPARTMENT = "Florida Department of Health"
  ACRONYM = "FDOH"

  def self.state_name
    "Florida"
  end

  def self.gallery_url
    "https://fdoh.maps.arcgis.com/home/gallery.html"
  end

  def self.counties_feature_url
    "https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/ArcGIS/rest/services/Florida_COVID19_Cases/FeatureServer/0"
  end

  def self.cases_feature_url
    "https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/arcgis/rest/services/Florida_COVID19_Case_Line_Data_NEW/FeatureServer/0"
  end

  def self.dashboard_url
    "https://experience.arcgis.com/experience/96dd742462124fa0b38ddedb9b25e429"
  end

  def self.beds_county_current_url
    "https://bi.ahca.myflorida.com/t/ABICC/views/Public/HospitalBedsCounty.csv"
  end

  def self.icu_county_current_url
    "https://bi.ahca.myflorida.com/t/ABICC/views/Public/ICUBedsCounty.csv"
  end

  def self.covid_hospitalizations_county_url
    "https://bi.ahca.myflorida.com/t/ABICC/views/Public/COVIDHospitalizationsCounty.csv"
  end

  def self.county_exclusion_field
    {
      field_name: :COUNTYNAME,
      field_value: "A State"
    }
  end

  def self.case_keys
    @_case_keys ||= {
      positives: {
        name: "Positives",
        description: "Includes both Florida residents and non-residents.",
        count_of_total_records: true,
        highlight: true
      },
      deaths: {
        name: "Deaths",
        positive_value: "Yes",
        highlight: true,
        source: :Died
      },
      deaths_unknown: {
        name: "Deaths - Unavailable",
        positive_value: "NA",
        description: "Cases for which there is currently no information about death.",
        source: :Died
      },
      hospitalized_yes: {
        name: "Hospitalized - Yes",
        description: "Includes both Florida residents and non-residents unlike the FDOH dashboard which excludes non-residents in 'Hospitalizations'",
        positive_value: "YES",
        highlight: true,
        source: :Hospitalized
      },
      hospitalized_no: {
        name: "Hospitalized - No",
        description: "Includes both Florida residents and non-residents unlike the FDOH dashboard which excludes non-residents in 'Hospitalizations'",
        positive_value: "NO",
        source: :Hospitalized
      },
      emergency_visits_yes: {
        name: "Emergency Visits - Yes",
        positive_value: "YES",
        source: :EDvisit
      },
      emergency_visits_no: {
        name: "Emergency Visits - No",
        positive_value: "NO",
        source: :EDvisit
      },
      travel_related_yes: {
        name: "Travel Related - Yes",
        positive_value: "Yes",
        source: :Travel_related
      },
      travel_related_no: {
        name: "Travel Related - No",
        positive_value: "No",
        source: :Travel_related
      },
      residents: {
        name: "Florida Residents",
        positive_value: "FL resident",
        source: :Jurisdiction
      },
      non_residents: {
        name: "Non-Florida Residents",
        positive_value: "Non-FL resident",
        source: :Jurisdiction
      },
      not_diagnosed_in_florida: {
        name: "Not diagnosed/isolated in Florida",
        positive_value: "Not diagnosed/isolated in FL",
        source: :Jurisdiction
      },
      contact_yes: {
        name: "Contact with COVID-19 positive - Yes",
        positive_value: "YES",
        highlight: true,
        source: :Contact
      },
      contact_no: {
        name: "Contact with COVID-19 positive - No",
        positive_value: "NO",
        source: :Contact
      },
      contact_unknown: {
        name: "Contact with COVID-19 positive - Unknown",
        positive_value: "UNKNOWN",
        description: "Number of people who are monitored but have yet to be contacted by a contact tracer.",
        source: :Contact
      },
      contact_not_available: {
        name: "Contact with COVID-19 positive - NA",
        positive_value: "NA",
        description: "It's unclear how and why this field is different from NO and UNKNOWN values of the Contact field.",
        source: :Contact
      },
      origin_not_available: {
        name: "Origin - Not Available",
        positive_value: "NA",
        description: "Cases for which the likely origin for where the virus was contracted before arriving/returning to Florida was not traced yet.",
        source: :Origin
      },
      origin_ny: {
        name: "Origin - New York",
        positive_value: "NY",
        description: "Cases for which the likely origin for where the virus was contracted before arriving/returning to Florida was New York State.",
        source: :Origin
      },
      origin_fl_ny: {
        name: "Origin - Florida & New York State",
        positive_value: "FL; NY",
        description: "Cases for which the likely origin for where the virus was contracted before arriving/returning to Florida was Florida and New York State.",
        source: :Origin
      },
      origin_fl_ga: {
        name: "Origin - Florida & Georgia",
        positive_value: "FL; GA",
        description: "Cases for which the likely origin for where the virus was contracted before arriving/returning to Florida was Florida and Georgia.",
        source: :Origin
      },
      origin_ga: {
        name: "Origin - Georgia",
        positive_value: "GA",
        description: "Cases for which the likely origin for where the virus was contracted before arriving/returning to Florida was Georgia.",
        source: :Origin
      },
      origin_spain: {
        name: "Origin - Spain",
        positive_value: "SPAIN",
        description: "Cases for which the likely origin for where the virus was contracted before arriving/returning to Florida was Spain.",
        source: :Origin
      },
      origin_new_jersey: {
        name: "Origin - New Jersey",
        positive_value: "NJ",
        description: "Cases for which the likely origin for where the virus was contracted before arriving/returning to Florida was New Jersey.",
        source: :Origin
      },
      origin_co: {
        name: "Origin - Colorado",
        positive_value: "CO",
        description: "Cases for which the likely origin for where the virus was contracted before arriving/returning to Florida was Colorado.",
        source: :Origin
      },
      origin_fl_unknown: {
        name: "Origin - Florida & Unknown",
        positive_value: "FL; UNKNOWN",
        description: "Cases for which the likely origin for where the virus was contracted before arriving/returning to Florida was Florida and some other unknown location.",
        source: :Origin
      },
      origin_fl_nj: {
        name: "Origin - Florida & New Jersey",
        positive_value: "FL; NJ",
        description: "Cases for which the likely origin for where the virus was contracted before arriving/returning to Florida was Florida and New Jersey.",
        source: :Origin
      },
      female: {
        name: "Female",
        positive_value: "Female",
        source: :Gender
      },
      male: {
        name: "Male",
        positive_value: "Male",
        source: :Gender
      },
      unknown_gender: {
        name: "Unknown Gender",
        positive_value: "Unknown",
        source: :Gender
      }
    }
  end

  def self.county_keys
    {
      age_0_to_4: {
        name: "PUIs - Age - 0 to 4",
        source: :Age_0_4
      },
      age_5_to_14: {
        name: "PUIs - Age - 5 to 14",
        source: :Age_5_14
      },
      age_15_to_24: {
        name: "PUIs - Age - 15 to 24",
        source: :Age_15_24
      },
      age_25_to_34: {
        name: "PUIs - Age - 25 to 34",
        source: :Age_25_34
      },
      age_35_to_44: {
        name: "PUIs - Age - 35 to 44",
        source: :Age_35_44
      },
      age_45_to_54: {
        name: "PUIs - Age - 45 to 54",
        source: :Age_45_54
      },
      age_55_to_64: {
        name: "PUIs - Age - 55 to 64",
        source: :Age_55_64
      },
      age_65_to_74: {
        name: "PUIs - Age - 65 to 74",
        source: :Age_65_74
      },
      age_75_to_84: {
        name: "PUIs - Age - 75 to 84",
        source: :Age_75_84
      },
      age_85_and_over: {
        name: "PUIs - Age - 85 and over",
        source: :Age_85plus
      },
      age_unknown: {
        name: "PUIs - Age - Unknown",
        source: :Age_Unkn
      },
      PUIs_residents: {
        name: "PUIs - Residents",
        source: :PUIFLRes
      },
      PUIs_non_residents: {
        name: "PUIs - Non-residents",
        description: "Number of PUIs who are under surveillance in Florida but are not residents of the state",
        source: :PUINotFLRes
      },
      PUIs_residents_out: {
        name: "PUIs - Residents Out of State",
        description: "Number of PUIs who are Florida residents located in Florida",
        source: :PUIFLResOut
      },
      PUIs_female: {
        name: "PUIs - Female",
        description: "Number of female PUIs",
        source: :PUIFemale
      },
      PUIs_male: {
        name: "PUIs - Male",
        description: "Number of male PUIs",
        source: :PUIMale
      },
      PUIs_sex_unknown: {
        name: "PUIs - Sex Unknown",
        description: "Number of PUIs where sex was not listed",
        source: :PUISexUnkn
      },
      PUIs_contact_no: {
        name: "PUIs - Cont - No",
        description: "PUIs with no known contact with current or previous confirmed cases",
        source: :PUIContNo
      },
      PUIs_contact_unknown: {
        name: "PUIs - Cont - Unknown",
        description: "PUIs where contact with current or previous confirmed cases is not known or under investigation",
        source: :PUIContUnkn
      },
      PUIs_age_average: {
        name: "PUIs - Age - Average",
        source: :PUIAgeAvrg
      },
      PUIs_travel_yes: {
        name: "PUIs - Travel - Yes",
        description: "Total PUIs designated who recently traveled overseas or to an area with community spread",
        source: :PUITravelYes
      },
      PUIs_travel_no: {
        name: "PUIs - Travel - No",
        description: "Total PUIs designated as not being a risk related to recent travel",
        source: :PUITravelNo
      },
      PUIs_travel_unknown: {
        name: "PUIs - Travel - Unknown",
        description: "Total PUIs designated where a travel-related designation has not yet been made",
        source: :PUITravelUnkn
      },
      positive_age_0_to_4: {
        name: "Positives - Age - 0 to 4",
        source: :C_Age_0_4
      },
      positive_age_5_to_14: {
        name: "Positives - Age - 5 to 14",
        source: :C_Age_5_14
      },
      positive_age_15_to_24: {
        name: "Positives - Age - 15 to 24",
        source: :C_Age_15_24
      },
      positive_age_25_to_34: {
        name: "Positives - Age - 25 to 34",
        source: :C_Age_25_34
      },
      positive_age_35_to_44: {
        name: "Positives - Age - 35 to 44",
        source: :C_Age_35_44
      },
      positive_age_45_to_54: {
        name: "Positives - Age - 45 to 54",
        source: :C_Age_45_54
      },
      positive_age_55_to_64: {
        name: "Positives - Age - 55 to 64",
        source: :C_Age_55_64
      },
      positive_age_65_to_74: {
        name: "Positives - Age - 65 to 74",
        source: :C_Age_65_74
      },
      positive_age_75_to_84: {
        name: "Positives - Age - 75 to 84",
        source: :C_Age_75_84
      },
      positive_age_85_and_over: {
        name: "Positives - Age - 85 and over",
        source: :C_Age_85plus
      },
      positive_age_unknown: {
        name: "Positives - Age - Unknown",
        source: :C_Age_Unkn
      },
      positive_age_median: {
        name: "Positives - Age - Median",
        source: :C_AgeMedian,
        total: true
      },
      positive_age_range: {
        name: "Positives - Age Range",
        source: :C_AgeRange,
        total: true
      },
      positive_all_residence_types: {
        name: "Positives - All Residence Types",
        description: "Sum of all Florida residents in and outside of Florida who tested COVID-19 Positive.",
        source: :C_AllResTypes
      },
      positive_women: {
        name: "Positives - Women",
        description: "Sex listed as Female",
        source: :C_Women
      },
      positive_men: {
        name: "Positives - Men",
        source: :C_Men
      },
      positive_sex_unknown: {
        name: "Positives - Sex Unknown",
        description: "Sex data is missing or listed as “Unknown”",
        source: :C_SexUnkn
      },
      positives_race_white: {
        name: "Positives - Race - White",
        description: "Race is listed as White",
        source: :C_RaceWhite
      },
      positives_race_black: {
        name: "Positives - Race - Black",
        description: "Race is listed as Black",
        source: :C_RaceBlack
      },
      positives_race_other: {
        name: "Positives - Race - Other",
        description: "Race is listed as Other",
        source: :C_RaceOther
      },
      positives_race_unknown: {
        name: "Positives - Race - Unknown",
        description: "Race data is missing or listed as “Unknown”",
        source: :C_RaceUnknown
      },
      positives_hispanic_yes: {
        name: "Positives - Hispanic - Yes",
        description: "Ethnicity is listed as Hispanic",
        source: :C_HispanicYES
      },
      positives_hispanic_no: {
        name: "Positives - Hispanic - No",
        description: "Ethnicity is listed as NOT Hispanic",
        source: :C_HispanicNO
      },
      positives_hispanic_unknown: {
        name: "Positives - Hispanic - Unknown",
        source: :C_HispanicUnk
      },
      inconclusive_total: {
        name: "Inconclusive Test Results - Total",
        source: :TInconc
      },
      monitored_cumulative: {
        name: "Monitored - Cumulative Total",
        description: "Total number of cases that were at any point being monitored",
        source: :EverMon
      },
      monitored_currently: {
        name: "Monitored - Current Total",
        description: "Total number of currently monitored persons by county",
        source: :MonNow
      },
      cases_all: {
        name: "Cases - All",
        highlight: true,
        description: "The sum total of all positive cases, including Florida residents in Florida, Florida residents outside Florida, and non-Florida residents in Florida",
        source: :CasesAll
      },
      positives_total: {
        name: "Positive Tests - Total",
        description: "Florida and non-Florida residents, including residents tested outside of the Florida, and at private facilities.",
        highlight: true,
        source: :T_positive
      },
      positives_total_excluding: {
        name: "Positive Tests - Total (Excluding Pending & Awaiting)",
        description: "Number of PUIs with test results, including negative, positive and inconclusive, but excluding pending or awaiting testing. This is the total number of people with test results in our system.",
        source: :TPositive
      },
      negatives_total: {
        name: "Negative Tests - Total",
        description: "Florida and non-Florida residents, including residents tested outside of the Florida, and at private facilities.",
        highlight: true,
        source: :T_negative
      },
      pending_total: {
        name: "Pending Tests - Total",
        description: "Test administered but results pending.",
        highlight: true,
        source: :TPending
      },
      cumulative_hospitalized_residents: {
        name: "Positives - Hospitalization FL Residents",
        description: "Inpatient hospitalizations of confirmed-positive Florida residents only. ",
        source: :C_HospYes_Res,
        highlight: true
      },
      cumulative_hospitalized_non_residents: {
        name: "Positives Hospitalization Non-FL Residents",
        description: "Inpatient hospitalizations of confirmed-positive non-Florida residents only. ",
        source: :C_HospYes_NonRes,
        highlight: true
      },
      positive_emergency_yes_resident: {
        name: "Positive - Emergency - Residents",
        description: "Emergency Dept Admissions for Florida Residents Only.",
        source: :C_EDYes_Res
      },
      positive_emergency_yes_non_resident: {
        name: "Positive - Emergency - Non-residents",
        description: "Emergency Dept Admissions for Non-Florida Residents.",
        source: :C_EDYes_NonRes
      },
      positive_florida_residents: {
        name: "Positive - Florida Residents",
        description: "Positive Florida Residents in Florida",
        source: :C_FLRes
      },
      positive_non_florida_residents: {
        name: "Positive - Non-Florida Residents",
        description: "Positive Non-Florida Residents in Florida",
        source: :C_NotFLRes
      },
      positive_florida_residents_out: {
        name: "Positive - Florida Residents Outside Florida",
        description: "Total number of positive Florida Residents exposed/tested/isolated outside of Florida",
        source: :C_FLResOut
      },
      tests_negative_residents: {
        name: "Tested - Negative Residents",
        description: "Total number of negative Florida Residents tested.",
        source: :T_NegRes
      },
      tests_negative_non_residents: {
        name: "Tested - Negative Non-Residents",
        description: "Total number of negative non-Florida residents in Florida tested.",
        source: :T_NegNotFLRes
      },
      tests_total: {
        name: "Tested - Total",
        description: "Total tests administered or pending for all PUIs, including positive, negative and pending results. This matches the state report's 'Total tested' in the 'Persons tested' summary.",
        highlight: true,
        source: :T_total
      },
      tests_total_residents: {
        name: "Tested - Residents - Total",
        description: "Total tests administered or pending for all PUIs that are Florida residents, including positive, negative and pending results.",
        source: :T_total_Res
      },
      tests_private_lab_residents: {
        name: "Tested - Residents - Private Lab",
        description: "Total positive persons who are residents of Florida and had confirmed lab results by a private or commercial lab/hospital/facility",
        source: :T_LabPrivate_Res
      },
      tests_doh_residents: {
        name: "Tested - Residents - DOH",
        description: "Total positive persons who are residents of Florida and had confirmed lab results by a private or commercial lab/hospital/facility",
        source: :T_LabDOH_Res
      },
      tests_private_lab_non_residents: {
        name: "Tested - Non-residents - Private Lab",
        description: "Total positive persons who are NOT residents of Florida and had confirmed lab results by a private or commercial lab/hospital/facility",
        source: :T_LabPrivate_NonRes
      },
      tests_doh_non_residents: {
        name: "Tested - Non-residents - DOH",
        description: "Total positive persons who are NOT residents of Florida and had confirmed lab results by CDC or BPHL",
        source: :T_LabDOH_NonRes
      },
      PUIs_total: {
        name: "PUIs - Total",
        description: "The sum of all Persons Under Investigations (PUIs) in the state's database system as of the time of data publication. Includes Florida Residents, Non- Florida residents in Florida, and some Florida residents who are not currently in Florida",
        highlight: true,
        source: :PUIsTotal
      },
      deaths_residents: {
        name: "Deaths - Residents",
        description: "May be out of date compared to the individual case death total which is updated more frequently.",
        highlight: true,
        source: :C_FLResDeaths
      },
      deaths_non_residents: {
        name: "Deaths - Non-residents",
        description: "May be out of date compared to the individual case death total which is updated more frequently.",
        highlight: true,
        source: :C_NonResDeaths
      },
      deaths: {
        name: "Deaths",
        description: "Florida does not report out-of-state resident deaths as part of its deaths total.",
        highlight: true,
        source: :Deaths
      }
    }
  end

  def self.bed_keys
    @_case_keys ||= {
      census: {
        name: "Bed Census",
        source: :"Bed Census"
      },
      available: {
        name: "Available",
        source: :"Available"
      },
      available_capacity: {
        name: "Available Capacity",
        percentage: true,
        source: :"Available Capacity"
      },
      staffed_capacity: {
        name: "Total Staffed Bed Capacity",
        source: :"Total Staffed Bed Capacity"
      }
    }
  end

  def self.icu_keys
    @_icu_keys ||= {
      adult_census: {
        name: "Adult ICU Census",
        source: :"Adult ICU Census"
      },
      available_adult: {
        name: "Available Adult ICU",
        source: :"Available Adult ICU"
      },
      total_adult_capacity: {
        name: "Total AdultICU Capacity",
        source: :"Total AdultICU Capacity"
      },
      available_adult_percentage: {
        name: "Available Adult ICU%",
        source: :"Available Adult ICU%",
        percentage: true
      },
      pediatric_census: {
        name: "Pediatric ICU Census",
        source: :"Pediatric ICU Census"
      },
      available_pediatric: {
        name: "Available Pediatric ICU",
        source: :"Available Pediatric ICU"
      },
      total_pediatric_capacity: {
        name: "Total PediatricICU Capacity",
        source: :"Total PediatricICU Capacity"
      },
      available_pediatric_percentage: {
        name: "Available Pediatric ICU%",
        source: :"Available Pediatric ICU%",
        percentage: true
      },
    }
  end

  def self.covid_hospitalizations_keys
    @_covid_hospitalizations_keys ||= {
      hospitalizations: {
        name: "Total COVID Hospitalizations",
        source: :"COVID Hospitalizations",
        hightlight: true,
        description: "Tally of all *current* hospitalizations with a primary diagnosis of COVID-19. Updated continuously throughout the day."
      }
    }
  end
end
