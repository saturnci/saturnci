#!/bin/bash
bundle exec rails db:drop \
  db:create \
  assets:precompile
