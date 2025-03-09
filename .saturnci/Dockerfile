# Build stage
FROM ruby:3.3.5-slim AS builder
WORKDIR /code

# Install only the necessary build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nodejs \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install gems - use --without if you don't need development/test gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy only files needed for asset precompilation
COPY app/assets ./app/assets
COPY app/javascript ./app/javascript
COPY app/views ./app/views
COPY config/environments ./config/environments
COPY config/initializers ./config/initializers
COPY config/application.rb config/boot.rb config/environment.rb ./config/
COPY public ./public

# Set environment variables
ENV RAILS_ENV=production
ENV DATABASE_NAME=dummy_database_name
ENV DATABASE_USERNAME=dummy_database_username
ENV DATABASE_PASSWORD=dummy_database_password
ENV DATABASE_HOST=localhost
ENV DATABASE_PORT=5432

# Precompile assets
RUN bundle exec rails assets:precompile \
    && rm -rf tmp/cache node_modules .git

# Runtime stage
FROM ruby:3.3.5-slim
WORKDIR /code

# Install only runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV RAILS_ENV=production
ENV DATABASE_NAME=dummy_database_name
ENV DATABASE_USERNAME=dummy_database_username
ENV DATABASE_PASSWORD=dummy_database_password
ENV DATABASE_HOST=localhost
ENV DATABASE_PORT=5432
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

# Copy gems from builder stage
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copy application code
COPY --from=builder /code/public/assets /code/public/assets
COPY --from=builder /code/public/packs /code/public/packs
COPY . ./

# Expose port and run server
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
