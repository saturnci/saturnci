# SaturnCI Test Environment Docker Image
#
# This Dockerfile creates the container image that SaturnCI uses to run
# your tests. It includes all necessary dependencies for a Rails application with
# PostgreSQL and handles asset precompilation during the build process.
#
# This image is used by .saturnci/docker-compose.yml to create the test execution environment.

# Use ruby:3.3.5-slim as the base image. This provides a pre-built Linux
# environment with Ruby already installed. The "slim" version contains only
# essential packages, making it smaller and faster to download.
FROM ruby:3.3.5-slim

# Set /app as the working directory. All subsequent commands will run from here.
WORKDIR /app

ENV RAILS_ENV=test

# Update the package list to get the latest available packages.
RUN apt-get update && apt-get install -y \

    # Install compilers and build tools needed for native gem compilation.
    build-essential \

    # Install PostgreSQL client libraries for database connections.
    libpq-dev \

    # Install JavaScript runtime for asset processing.
    nodejs \

    # Install version control system for dependency management.
    git \

    # Clean up package cache to reduce image size.
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install && rm -rf /usr/local/bundle/cache/*

# Copy all application files. Use .dockerignore to exclude unnecessary files.
COPY . ./

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

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
