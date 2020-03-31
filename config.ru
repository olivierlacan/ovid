require 'rubygems'
require 'bundler'

Bundler.require

require "./flovid"

if Flovid.development?
  require 'dotenv'
  Dotenv.load
else
  Bugsnag.configure do |config|
    config.api_key = ENV["BUGSNAG_API_KEY"]
  end

  use Bugsnag::Rack
end

run lambda { |env|
  [
    200,
    {'Content-Type'=>'text/html'},
    StringIO.new(payload)
    ]
}

def payload
  <<~HTML
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <title>Florida COVID-19 Report</title>
    <style type="text/css">
      body {
        font-family: Tahoma, sans-serif;
      }
      th, td {
        padding: 0.3rem 1rem;
      }
      th {
        width: 50%;
      }

      td {
        width: 50%;
      }

      td:first-child, th:first-child {
        text-align: right;
      }

      td:last-child, th:last-child {
        text-align: left;
      }

      tr:nth-child(even) { background: #CCC }
      tr:nth-child(odd) { background: #FFF }
    </style>
  </head>
  <body>
    <h1>Florida COVID-19 Report</h1>
    <p>
      This report is generated from the Florida Department of Health's
      <a href="https://fdoh.maps.arcgis.com/home/item.html?id=f5d69a918fb747019734d9a90cd602f4">
      <em>COVID -19 Testing Data for the State of Florida</em></a> feature layer hosted
      on the <a href="https://fdoh.maps.arcgis.com/home/index.html">FDOH's Esri ARCGIS</a>
      account.
    </p>

    #{report_table}

    <p><code>*</code> denotes metrics tracked by the COVID Tracking Project</p>
  </body>
  </html>
  HTML
end

def report_table
  rows = Flovid.covid_tracking_report.map do |_key, metric|
    <<~HTML
      <tr>
        <td title="#{metric["source"]}">#{metric[:name]}#{"*" if metric[:highlight]}</td>
        <td>#{metric[:value]}</td>
      </tr>
    HTML
  end.join("\n")

  output = <<~HTML
    <table>
      <tr>
        <th>Metric</th>
        <th>Value</th>
      </tr>
      #{rows}
    </table>
  HTML
end
