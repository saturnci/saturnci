# Use the Ruby 3.1.2 image from Docker Hub as the base image
FROM ruby:3.1.2

# Use a directory called /code in which to store this application's files.
WORKDIR /code

# Install Ruby dependencies
COPY Gemfile Gemfile.lock /code/
RUN bundle install

# Install Yarn dependencies
COPY package.json yarn.lock /code/
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn && \
    yarn install --check-files

# Copy the rest of the application
COPY . /code

# Set "rails server -b 0.0.0.0" as the command to run when this container starts.
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
