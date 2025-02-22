#!/bin/bash
docker-compose -f .saturnci/docker-compose.yml run saturn_test_app $@
