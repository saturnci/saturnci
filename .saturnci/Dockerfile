FROM ruby:3.3.5

# This is an arbitrary change to test image caching

WORKDIR /code

COPY Gemfile Gemfile.lock /code/
RUN bundle install

COPY . /code

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
