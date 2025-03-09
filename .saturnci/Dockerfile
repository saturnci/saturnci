# Build stage
FROM ruby:3.3.5-slim AS builder
WORKDIR /code
ENV RAILS_ENV=test

# Install minimal required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nodejs \
    git \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install gems once
COPY Gemfile Gemfile.lock ./
RUN bundle install \
    && rm -rf /usr/local/bundle/cache/*

# Copy only files needed for asset precompilation
COPY app/assets ./app/assets
COPY app/javascript ./app/javascript
COPY app/views ./app/views
COPY config/environments ./config/environments
COPY config/initializers ./config/initializers
COPY config/application.rb config/boot.rb config/environment.rb ./config/
COPY public ./public

# Set dummy environment variables for asset compilation
ENV DATABASE_NAME=dummy_database_name
ENV DATABASE_USERNAME=dummy_database_username
ENV DATABASE_PASSWORD=dummy_database_password
ENV DATABASE_HOST=localhost
ENV DATABASE_PORT=5432

# Precompile assets
RUN bundle exec rails assets:precompile \
    && rm -rf tmp/cache tmp/webpacker node_modules/.cache

# Final stage
FROM ruby:3.3.5-slim
WORKDIR /code
ENV RAILS_ENV=test

# Install only runtime dependencies (no build-essential needed if tests don't require compilation)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    nodejs \
    git \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Copy gems from builder stage
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copy pre-compiled assets from builder stage
COPY --from=builder /code/public/assets ./public/assets
COPY --from=builder /code/public/packs ./public/packs

# Set environment variables
ENV DATABASE_NAME=dummy_database_name
ENV DATABASE_USERNAME=dummy_database_username
ENV DATABASE_PASSWORD=dummy_database_password
ENV DATABASE_HOST=localhost
ENV DATABASE_PORT=5432

# Copy application code
COPY . ./

# Run server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
