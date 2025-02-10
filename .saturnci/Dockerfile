FROM ruby:3.3.5

WORKDIR /code

# Install PostgreSQL client 17 and dependencies
RUN apt-get update && apt-get install -y wget gnupg2 lsb-release && \
    DISTRO=$(lsb_release -cs) && \
    echo "deb http://apt.postgresql.org/pub/repos/apt ${DISTRO}-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list && \
    wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && apt-get install -y postgresql-client-17 && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock /code/
RUN bundle install

COPY . /code

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
