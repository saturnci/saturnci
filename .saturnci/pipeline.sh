#!/bin/bash

CREDS_FILE="$HOME/.saturnci/credentials.json"
HOST="${SATURNCI_HOST:-https://app.saturnci.com}"
REPOSITORY="${SATURNCI_REPOSITORY:-saturnci/saturnci}"
COMMIT="${1:-$(git rev-parse HEAD)}"
BRANCH="${2:-main}"
MESSAGE="${3:-$(git log -1 --format=%s)}"
AUTHOR="${4:-Jason Swett}"

USER_ID=$(jq -r '.user_id' "$CREDS_FILE")
API_TOKEN=$(jq -r '.api_token' "$CREDS_FILE")

curl -X POST "$HOST/api/v1/test_suite_runs" \
  -u "$USER_ID:$API_TOKEN" \
  -d "repository=$REPOSITORY" \
  -d "commit_hash=$COMMIT" \
  -d "branch_name=$BRANCH" \
  -d "commit_message=$MESSAGE" \
  -d "author_name=$AUTHOR"
