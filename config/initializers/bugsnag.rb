Bugsnag.configure do |config|
  config.api_key = ENV["BUGSNAG_API_KEY"]
  config.release_stage = ENV["RAILS_ENV"] || "development"
  config.notify_release_stages = ["production"]
end
