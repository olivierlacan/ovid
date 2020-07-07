class Application
  def self.pretty_datetime(time)
    format = "%Y-%m-%d at %H:%M:%S %Z".freeze

    if time.respond_to? :strftime
      time.strftime(format)
    else
      Time.parse(time).strftime(format)
    end
  end

  def self.state_links
    State.all_states.map do |state|
      <<~HTML
        <li><a href="/#{state.parameterize}">#{state.state_name}</a></li>
      HTML
    end.join("\n")
  end

  def self.payload(query_string, class_name)
    <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>#{class_name ? class_name.state_name + " " : nil}Ovid COVID-19 report</title>
      <style type="text/css">
        #{css}
      </style>
    </head>
    <body>
      <nav>
        <ul>
          <li><a href="/">Home</a></li>
          #{state_links}
        </ul>
      </nav>

      #{class_name ? state_page(class_name, query_string) : home_page}

      <hr />
      <p>
        <a href="https://github.com/olivierlacan/ovid/">Source code for this website</a>
         - Maintained by <a href="https://olivierlacan.com">Olivier Lacan</a> for <a href="https://covidtracking.com/">The COVID Tracking Project</a>
      </p>
    </body>
    </html>
    HTML
  end

  def self.home_page
    <<~HTML
      <h1>Ovid</h1>
      <p>
        This project aggregates county-level data from U.S. states for
        which ArcGIS public Feature Layers (datasets) are available.
      </p>

      <p>
        While this data may not always be authoritative, it allows for
        COVID-19 case and testing information released by states in
        other avenues to be compared with raw data emanating from their
        own counties.
      </p>

      <p>
        Please corroborate this data prior to use in any journalistic or
        data scientific endeavor. State pages link to ArcGIS dashboards
        whenever possible and the source feature layers are listed to
        help independent
        verification.
      </p>
    HTML
  end

  def self.case_report(class_name, query_string)
    return nil if class_name.cases_feature_url.nil?

    case_report = class_name.case_report(query_string)

    # empty report
    if case_report&.public_send(:[],:data).nil?
      return nil
    end

    last_edit_case = pretty_datetime case_report[:edited_at]
    last_fetch_case = pretty_datetime case_report[:fetched_at]

    payload = ""

    if case_report&.public_send(:[],:refreshing) == true
      payload << <<~HTML
        <h2>Data Aggregated from Individual Cases</h2>
        <p>
          Source: <a href="#{class_name.cases_feature_url}">ArcGIS Feature Layer</a>.<br />
          Edited by #{class_name::ACRONYM} at <strong>#{last_edit_case}</strong>.<br />
          Fetched at <strong>#{last_fetch_case}</strong><br />
        </p>

        <p>Case line data is being refreshed, please reload in a few seconds...</p>
      HTML
    else
      payload << <<~HTML
        <h2>Data Aggregated from Individual Cases</h2>
        <p>
          Source: <a href="#{class_name.cases_feature_url}">ArcGIS Feature Layer</a>.<br />
          Edited by #{class_name::ACRONYM} at <strong>#{last_edit_case}</strong>.<br />
          Fetched at <strong>#{last_fetch_case}</strong> (refreshing now).<br />
        </p>

        #{report_table(case_report[:data])}
      HTML
    end

    payload
  end

  def self.county_report(class_name, query_string)
    county_report = class_name.county_report(query_string)

    return nil if county_report&.public_send(:[],:data).nil?

    last_edit_county = pretty_datetime county_report[:edited_at]
    last_fetch_county = pretty_datetime county_report[:fetched_at]

    <<~HTML
      <h2>Data Aggregated from County Totals</h2>
      <p>
        Source: <a href="#{class_name.counties_feature_url}">ArcGIS Feature Layer</a>.<br />
        Edited by #{class_name::ACRONYM} at <strong>#{last_edit_county}</strong>.<br />
        Fetched at <strong>#{last_fetch_county}</strong>.<br />
      </p>
      #{report_table(county_report[:data])}
    HTML
  end

  def self.totals_report(class_name, query_string)
    totals_report = class_name.totals_report(query_string)

    return nil if totals_report&.public_send(:[],:data).nil?

    last_edit_totals = pretty_datetime totals_report[:edited_at]
    last_fetch_totals = pretty_datetime totals_report[:fetched_at]

    <<~HTML
      <h2>State Level Totals</h2>
      <p>
        Source: <a href="#{class_name.totals_feature_url}">ArcGIS Feature Layer</a>.<br />
        Edited by #{class_name::ACRONYM} at <strong>#{last_edit_totals}</strong>.<br />
        Fetched at <strong>#{last_fetch_totals}</strong>.<br />
      </p>
      #{report_table(totals_report[:data])}
    HTML
  end

  def self.hospitals_report(class_name, query_string)
    hospitals_report = class_name.hospitals_report(query_string)

    return nil if hospitals_report&.public_send(:[],:data).nil?

    last_edit_totals = pretty_datetime hospitals_report[:edited_at]
    last_fetch_totals = pretty_datetime hospitals_report[:fetched_at]

    <<~HTML
      <h2>Hospitalization Totals</h2>
      <p>
        Source: <a href="#{class_name.hospitals_feature_url}">ArcGIS Feature Layer</a>.<br />
        Edited by #{class_name::ACRONYM} at <strong>#{last_edit_totals}</strong>.<br />
        Fetched at <strong>#{last_fetch_totals}</strong>.<br />
      </p>
      #{report_table(hospitals_report[:data])}
    HTML
  end

  def self.state_page(class_name, query_string)

    <<~HTML
      <h1>#{class_name.state_name} COVID-19 Report</h1>
      <p>
        This report is generated from the same #{class_name::DEPARTMENT}'s COVID-19
        data used to generate the <a href="#{class_name.dashboard_url}">
        ArcGIS dashboard</a>.
      </p>

      #{totals_report(class_name, query_string)}

      #{case_report(class_name, query_string)}

      #{county_report(class_name, query_string)}

      #{hospitals_report(class_name, query_string)}

      <footer>
        #{class_name.nomenclature if defined?(class_name.nomenclature)}
      </footer>
    HTML
  end

  def self.report_table(data)
    rows = data.map do |_key, metric|
      <<~HTML
        <tr>
          <td title="#{metric[:source]}">#{metric[:name]}</td>
          <td class="#{'highlight' if metric[:highlight]}">#{metric[:value]}</td>
          <td>#{metric[:description]}</td>
        </tr>
      HTML
    end.join("\n")

    output = <<~HTML
      <table>
        <tr>
          <th>Metric</th>
          <th>Value</th>
          <th>Description</th>
        </tr>
        #{rows}
      </table>
    HTML
  end

  def self.css
    <<~HTML
      body {
        font-family: Tahoma, sans-serif;
      }

      nav ul {
        padding: 0;
      }
      nav li {
        list-style: none;
        display: inline-block;
      }

      table {
        width: 100%
      }
      th, td {
        padding: 0.3rem 1rem;
      }

      th {
        position: sticky;
        top: 15px;
        background: white;
      }

      td:first-child, th:first-child {
        text-align: right;
        width: 25%;
      }

      td:nth-child(2), th:nth-child(2) {
        text-align: right;
        width: 5%;
      }

      td:last-child, th:last-child {
        text-align: left;
        width: 70%;
      }

      tr:nth-child(even) { background: #CCC }
      tr:nth-child(odd) { background: #FFF }

      .highlight { font-weight: bold; }
    HTML
  end
end
