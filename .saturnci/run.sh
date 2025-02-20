#!/bin/bash
docker-compose --env-file /tmp/saturnci.env \
  -f .saturnci/docker-compose.yml \
  run saturn_test_app \
  bundle exec $@
