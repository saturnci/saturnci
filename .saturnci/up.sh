#!/bin/bash
docker-compose --env-file /tmp/saturnci.env \
  -f .saturnci/docker-compose.yml \
  up -d
