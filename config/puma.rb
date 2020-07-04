require "./config/boot"

workers ENV["RACK_ENV"] == "production" ? Integer(ENV['WEB_CONCURRENCY'] || 2) : 0
threads_count = 5
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'
