#!/bin/bash
bundle exec rails db:drop \
  db:create \
  db:schema:load \
  assets:precompile
