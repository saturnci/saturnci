# SaturnCI Test Environment Docker Image
#
# This Dockerfile creates the container image that SaturnCI uses to run
# your tests. It includes all necessary dependencies for a Rails application with
# PostgreSQL and handles asset precompilation during the build process.
#
# This image is used by .saturnci/docker-compose.yml to create the test execution environment.

FROM ruby:3.3.5-slim

WORKDIR /app

ENV RAILS_ENV=test

RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install && rm -rf /usr/local/bundle/cache/*

COPY app/assets ./app/assets
COPY app/javascript ./app/javascript
COPY app/views ./app/views
COPY config/environments ./config/environments
COPY config/initializers ./config/initializers
COPY config/application.rb config/boot.rb config/environment.rb ./config/
COPY public ./public

# Dummy database environment variables required for asset precompilation.
# Rails loads the application environment during asset compilation, which
# evaluates database.yml and may trigger database connections in initializers.
# These dummy values prevent build failures when no database is available.
ENV DATABASE_NAME=dummy_database_name
ENV DATABASE_USERNAME=dummy_database_username
ENV DATABASE_PASSWORD=dummy_database_password
ENV DATABASE_HOST=localhost
ENV DATABASE_PORT=5432

RUN bundle exec rails assets:precompile && \
    rm -rf tmp/cache node_modules/.cache

COPY . ./

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
