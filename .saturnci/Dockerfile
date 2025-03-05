FROM ruby:3.3.5

WORKDIR /code

ARG DOCKER_BUILD_CHECKSUM
RUN echo "DOCKER_BUILD_CHECKSUM: $DOCKER_BUILD_CHECKSUM"

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . ./

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
