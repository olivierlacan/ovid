class Request
  def self.get(url, params = {})
    params = params.merge({ f: "pjson" })
    uri = URI(url)
    uri.query = URI.encode_www_form(params)
    puts "Sending GET request to #{uri} ..."

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
      request = Net::HTTP::Get.new(uri)
      http.read_timeout = 120 # defaults to 60 seconds
      http.request(request)
    end

    if response.is_a?(Net::HTTPSuccess)
      puts "Apparent success!"
      parsed = JSON.parse(response.body, symbolize_names: true)

      raise parsed[:error] if parsed[:error]

      parsed
    else
      raise "#{response.code}: #{response.message}"
      puts "Headers: #{res.to_hash.inspect}"
      puts res.body if response.response_body_permitted?
    end
  rescue Net::ReadTimeout => error
    Bugsnag.notify(error) do |report|
      report.severity = "error"

      report.add_tab(:response, {
        url: cases_feature_url,
        metadata: metadata
      })
    end
  end
end
