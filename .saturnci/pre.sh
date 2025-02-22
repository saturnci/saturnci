#!/bin/bash
bundle exec rails db:create db:schema:load assets:precompile
