# frozen_string_literal: true

require "./lib/ovid"
require "./lib/application"

if Config.production?
  Bugsnag.configure do |config|
    config.api_key = ENV["BUGSNAG_API_KEY"]
  end

  use Bugsnag::Rack
  use Rack::SslEnforcer
end

app = Hanami::Router.new do
  if ENV["REDIRECT_TO_OVID"]
    redirect "/", to: "https://o-vid.herokuapp.com"
  else
    get "/", to: ->(env) {
      [
        200, {"Content-Type" => "text/html"},
        StringIO.new(Application.payload(nil))
      ]
    }
  end

  State.all_states.each do |state|
    if ENV["REDIRECT_TO_OVID"]
      redirect "/#{state.parameterize}", to: "https://o-vid.herokuapp.com/#{state.parameterize}"
    else
      get "/#{state.parameterize}", to: ->(env) {
        [
          200, {"Content-Type" => "text/html"},
          StringIO.new(Application.payload(state))
        ]
      }
    end
  end
end

run app


