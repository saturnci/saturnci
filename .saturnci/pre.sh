#!/bin/bash
rails db:create
rails db:schema:load
rails assets:precompile
