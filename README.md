# Ovid

Metamorphising raw COVID-19 JSON testing data from U.S. state Health Department
into high-level aggregate counts for journalistic, epidemiologic, and data
science purposes.

This project is currently hosted on [Heroku](https://flovid.herokuapp.com) and
serves as a data entry support tool for [COVID Tracking Project][CTP] volunteers.

## Sources

See individual state Ruby classes for state-specific sources. Source are
exclusively JSON feeds from ArcGIS and not scrapped HTML from state websites
because those have proven unreliable.

The following methods can be inspected on each state listed in `states/`:
- `testing_gallery_url`: URL to the general state or county gallery of ArcGIS data
- `testing_feature_url`: URL to the ArcGIS Feature Layer used as a source
- `testing_data_url`: URL to the JSON query outputing data from the Feature Layer.
- `dashboard_url`: URL to the state or county dashboard we sourced to find the
relevant Feature Layer

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
