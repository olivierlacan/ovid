require "./config/boot"

workers ENV["RACK_ENV"] == "production" ? Integer(ENV['WEB_CONCURRENCY'] || 2) : 0
threads_count = 5
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  Sidekiq.configure_client do |config|
    config.redis = Config.redis_pool
  end

  Sidekiq.configure_server do |config|
    config.redis = Config.redis_pool
  end
end
