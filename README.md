## Setup

```bash
bin/setup
```

## Run the server

```bash
bin/dev
ngrok http 3000 --domain=$(echo NGROK_URL)
```

## Docker registry cache

Every job run starts with an image build.
When no gems have changed, it's pointless to perform a bundle install as part of the build process since nothing in that image layer has changed.
In order to cache the parts of the image that can be cached, we use something called a Docker [registry cache](https://docs.docker.com/build/cache/backends/registry/).

A registry cache is a way to cache Docker images on a remote server.
When a test suite is run on SaturnCI, the project's image is fetched from the registry cache,
which may or may not have some of its layers cached.
After the test suite has run, the new latest image, which may differ from the cached image, is pushed to the registry cache to be used next time.

The relevant Kubernetes files are located in `ops/production/registry`.

Relevant:
- https://hub.docker.com/_/registry
- https://docs.docker.com/docker-hub/mirror/
- https://docs.docker.com/build/cache/backends/registry/

## To generate a new runner snapshot

```ruby
RunnerSnapshot.generate!
```

It will take a while for the snapshot to show up in the Snapshots area of Digital Ocean.

## Client setup

```Dockerfile
# .saturnci/Dockerfile

FROM ruby:3.3.5

WORKDIR /code

COPY Gemfile Gemfile.lock /code/
RUN bundle install

COPY . /code

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
```

```yaml
# .saturnci/docker-compose.yml

version: "3.8"

services:
  saturn_test_app:
    build:
      context: ../
      dockerfile: .saturnci/Dockerfile
    image: ${SATURN_TEST_APP_IMAGE_URL}
    volumes:
      - ../:/code
    depends_on:
      - postgres
      - redis
      - chrome
    environment:
      DOCKER_ENV: "true"
      DATABASE_USERNAME: saturn
      DATABASE_PASSWORD: ""
      DATABASE_HOST: postgres
      DATABASE_PORT: 5432
      RAILS_ENV: test
      REDIS_URL: redis://redis:6379/0
      SATURNCI_API_USERNAME: myuser
      SATURNCI_API_PASSWORD: mypassword

  postgres:
    image: postgres:13.1-alpine
    volumes:
      - postgresql:/var/lib/postgresql/data:delegated
      - ./init.sql:/data/application/init.sql
    ports:
      - "127.0.0.1:5432:5432"
    environment:
      PSQL_HISTFILE: /usr/src/app/log/.psql_history
      POSTGRES_USER: saturn
      POSTGRES_HOST_AUTH_METHOD: trust
    restart: on-failure
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U saturn"]
      interval: 10s
      timeout: 2s
      retries: 10
    logging:
      driver: none

  redis:
    image: redis:4.0.14-alpine
    volumes:
      - redis:/data:delegated
    ports:
      - "127.0.0.1:6379:6379"
    restart: on-failure
    logging:
      driver: none

  chrome:
    image: seleniarm/standalone-chromium
    hostname: chrome
    shm_size: 2g
    ports:
      - "4444:4444"

volumes:
  postgresql:
  redis:
```

```bash
.saturnci/pre.sh

#!/bin/bash
rails db:create
rails db:schema:load
rails assets:precompile
```
