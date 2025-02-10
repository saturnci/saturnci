FROM ruby:3.3.5

WORKDIR /code

# blah blah blah

COPY Gemfile Gemfile.lock /code/
RUN bundle install

COPY . /code

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
