FROM ruby:3.3.5

WORKDIR /code

RUN apt-get update -qq \
    && apt-get install -y build-essential libpq-dev postgresql-client-17

COPY Gemfile Gemfile.lock /code/
RUN bundle install

COPY . /code

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
