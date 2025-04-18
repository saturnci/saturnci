# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.5"

gem "rails", "~> 8.0.0.rc1"

gem "bootsnap", require: false
gem "importmap-rails"
gem "jbuilder"
gem "pg", "~> 1.1"
gem "puma", "~> 6.0"
gem "pundit"
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"
gem "sprockets-rails"
gem "stimulus-rails"
gem "turbo-rails", "~> 1.5"
gem "bugsnag"
gem "net-ssh"

# For soft deletion
gem "paranoia"

gem "audited"
gem "devise"
gem "view_component"

# For Digital Ocean
gem "droplet_kit"
gem "aws-sdk-s3"

# For GitHub authentication
gem "aws-sdk-secretsmanager", require: false
gem "faraday-retry", require: false
gem "jwt", require: false
gem "octokit", require: false
gem "omniauth-github"
gem "omniauth-rails_csrf_protection"

group :development, :test do
  gem "capybara", ">= 3.37.1"
  gem "debug", platforms: %i(mri mingw x64_mingw)
  gem "factory_bot_rails"
  gem "faker"

  gem "pry"
  gem "ostruct" # Needed for pry

  gem "rspec-rails"
  gem "webdrivers"
  gem "webmock"

  gem "dotenv-rails"
end

group :development do
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "web-console"
end
