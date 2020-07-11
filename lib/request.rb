class Request
  def self.get(url, params = {})
    params = params.merge({ f: "pjson" })
    uri = URI(url)
    uri.query = URI.encode_www_form(params)

    connection = Faraday.new(uri) do |builder|
      builder.request :timer
      builder.response :detailed_logger, Logger.new(STDOUT, level: Logger::INFO)
      builder.adapter :net_http_persistent do |http|
        http.read_timeout = 60
        http.idle_timeout = 30
      end
      builder.request :retry, {
        max: 3,
        interval: 0.05,
        interval_randomness: 0.5,
        backoff_factor: 2
      }
      builder.use FaradayMiddleware::FollowRedirects
    end

    puts "GET #{uri} ..."

    response = connection.get
    duration = response.env[:duration]

    if response.success?
      puts "Request duration: #{duration}"
      parsed = JSON.parse(response.body, symbolize_names: true)

      raise "#{parsed[:error]}" if parsed[:error]

      parsed
    else
      raise "#{response.status}: #{response.body}"
      puts "Headers: #{response.headers}"
      puts res.body
    end
  rescue Faraday::TimeoutError => error
    Bugsnag.notify(error) do |report|
      report.severity = "error"

      report.add_tab(:response, {
        url: cases_feature_url,
        metadata: metadata
      })
    end
  end
end
