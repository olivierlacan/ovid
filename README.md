# Ovid

Metamorphising raw COVID-19 JSON testing data from U.S. state Health Department
into high-level aggregate counts for journalistic, epidemiologic, and data
science purposes.

This project is currently hosted on [Heroku](https://o-vid.herokuapp.com) and
serves as a data entry support tool for [COVID Tracking Project][CTP] volunteers.

## Sources

See individual state Ruby classes for state-specific sources. Source are
exclusively JSON feeds from ArcGIS and not scrapped HTML from state websites
because those have proven unreliable.

The following methods can be inspected on each state listed in `states/`:
- `gallery_url`: general state or county gallery of ArcGIS data
- `cases_feature_url`: individual case datra
- `counties_feature_url`: county-level aggregate data
- `dashboard_url`: state or county dashboard sourced for feature layers

## Usage

### Running Site Locally

- `bundle install`
- `bundle exec rerun` (autoreloads on code changes)
- `bundle exec rackup` (needs to be shut down to update code)

## Additional Tooling

### Running Florida Case, Testing, and Deaths Parser

- `ruby parser.rb`

### Running California (Sonoma County) Parser

- `ruby parser_ca.rb`

[CTP]: https://covidtracking.com
