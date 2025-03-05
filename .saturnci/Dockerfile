FROM ruby:3.3.5

WORKDIR /code

COPY Gemfile Gemfile.lock /code/
RUN bundle install

COPY . /code

ENV DATABASE_NAME=dummy_database_name
ENV DATABASE_USERNAME=dummy_database_username
ENV DATABASE_PASSWORD=dummy_database_password
ENV DATABASE_HOST=localhost
ENV DATABASE_PORT=5432
RUN bundle exec rake assets:precompile

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
