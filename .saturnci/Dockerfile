FROM ruby:3.3.5

WORKDIR /code

COPY Gemfile Gemfile.lock /code/
RUN bundle install

COPY . /code
