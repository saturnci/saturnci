#!/bin/bash
bundle exec rails db:drop \
  db:create \
  db:test:load_schema \
  assets:precompile
