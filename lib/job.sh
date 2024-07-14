#!/bin/bash

USER_DIR=/home/ubuntu
PROJECT_DIR=$USER_DIR/project
SYSTEM_LOG_FILENAME=/var/log/syslog
TEST_OUTPUT_FILENAME=tmp/test_output.txt
TEST_RESULTS_FILENAME=tmp/test_results.txt

function api_request() {
    local method=$1
    local path=$2
    local data=$3

    curl -f -u $SATURNCI_API_USERNAME:$SATURNCI_API_PASSWORD \
        -X $method \
        -H "Content-Type: application/json" \
        -d "$data" \
        $HOST/api/v1/$path
}

function send_content_to_api() {
    local api_path=$1
    local content_type=$2
    local content=$3

    curl -f -u $SATURNCI_API_USERNAME:$SATURNCI_API_PASSWORD \
        -X POST \
        -H "Content-Type: $content_type" \
        -d "$content" "$HOST/api/v1/$api_path"
}

function send_file_content_to_api() {
    local api_path=$1
    local content_type=$2
    local file_path=$3

    curl -f -u $SATURNCI_API_USERNAME:$SATURNCI_API_PASSWORD \
        -X POST \
        -H "Content-Type: $content_type" \
        --data-binary "@$file_path" "$HOST/api/v1/$api_path"
}

function clone_user_repo() {
  TOKEN=$(api_request "POST" "github_tokens" "{\"github_installation_id\":\"$GITHUB_INSTALLATION_ID\"}")
  git clone https://x-access-token:$TOKEN@github.com/$GITHUB_REPO_FULL_NAME $PROJECT_DIR
  cd $PROJECT_DIR
  mkdir tmp
}

function run_pre_script() {
  sudo chmod 755 .saturnci/pre.sh

  sudo SATURN_TEST_APP_IMAGE_URL=$REGISTRY_CACHE_IMAGE_URL docker-compose \
    -f .saturnci/docker-compose.yml run saturn_test_app ./.saturnci/pre.sh
}

function start_test_suite() {
  cat <<EOF > ./example_status_persistence.rb
RSpec.configure do |config|
  config.example_status_persistence_file_path = '$TEST_RESULTS_FILENAME'
end
EOF

  TEST_FILES=$(find spec -name '*_spec.rb')
  TEST_GROUP=$(expr ${JOB_ORDER_INDEX} % ${NUMBER_OF_CONCURRENT_JOBS})
  SELECTED_TESTS=$(echo "${TEST_FILES}" | awk "NR % ${NUMBER_OF_CONCURRENT_JOBS} == ${TEST_GROUP}")
  echo $SELECTED_TESTS

  script -c "sudo SATURN_TEST_APP_IMAGE_URL=$REGISTRY_CACHE_IMAGE_URL docker-compose \
    -f .saturnci/docker-compose.yml run saturn_test_app \
    bundle exec rspec --require ./example_status_persistence.rb \
    --format=documentation --order rand:$RSPEC_SEED $(echo $SELECTED_TESTS)" \
    -f "$TEST_OUTPUT_FILENAME"
}

function stream_logs() {
    local api_path=$1
    local log_file_path=$2
    local last_line=0
    local log_sending_interval_in_seconds=1

    while true; do
        local current_number_of_lines_in_log_file=$(wc -l < $log_file_path)
        if [ $current_number_of_lines_in_log_file -gt $last_line ]; then
            local content=$(sed -n "$(($last_line + 1)),$current_number_of_lines_in_log_file p" $log_file_path)
            send_content_to_api $api_path "text/plain" "$content"
            last_line=$current_number_of_lines_in_log_file
        fi
        sleep $log_sending_interval_in_seconds
    done
}

#--------------------------------------------------------------------------------

echo "Starting to stream logs"
stream_logs "jobs/$JOB_ID/system_logs" $SYSTEM_LOG_FILENAME &

#--------------------------------------------------------------------------------

echo "Job machine ready"
api_request "POST" "jobs/$JOB_ID/job_events" '{"type":"job_machine_ready"}'

#--------------------------------------------------------------------------------

echo "Cloning user repo"
clone_user_repo
api_request "POST" "jobs/$JOB_ID/job_events" '{"type":"repository_cloned"}'

#--------------------------------------------------------------------------------

echo "Checking out commit $COMMIT_HASH"
git checkout $COMMIT_HASH

#--------------------------------------------------------------------------------

GEMFILE_LOCK_CHECKSUM=$(sha256sum Gemfile.lock | awk '{ print $1 }')
REGISTRY_CACHE_URL=registrycache.saturnci.com:5000
REGISTRY_CACHE_IMAGE_URL=$REGISTRY_CACHE_URL/saturn_test_app:$GEMFILE_LOCK_CHECKSUM
echo "Registry cache image URL: $REGISTRY_CACHE_IMAGE_URL"

echo "Authenticating to Docker registry"
sudo docker login $REGISTRY_CACHE_URL -u myusername -p mypassword

echo "Gemfile.lock checksum: $GEMFILE_LOCK_CHECKSUM"
echo "Pulling the existing image to avoid rebuilding if possible"
sudo docker pull $REGISTRY_CACHE_IMAGE_URL || true

#--------------------------------------------------------------------------------

echo "Running pre.sh"
api_request "POST" "jobs/$JOB_ID/job_events" '{"type":"pre_script_started"}'
run_pre_script
api_request "POST" "jobs/$JOB_ID/job_events" '{"type":"pre_script_finished"}'

#--------------------------------------------------------------------------------

echo "Starting to stream test output"
touch $TEST_OUTPUT_FILENAME
stream_logs "jobs/$JOB_ID/test_output" "$TEST_OUTPUT_FILENAME" &

echo "Running tests"
api_request "POST" "jobs/$JOB_ID/job_events" '{"type":"test_suite_started"}'
start_test_suite

#--------------------------------------------------------------------------------

echo "Job finished"
api_request "POST" "jobs/$JOB_ID/job_finished_events"

#--------------------------------------------------------------------------------

echo "Sending report"
send_file_content_to_api "jobs/$JOB_ID/test_reports" "text/plain" "$TEST_RESULTS_FILENAME"

#--------------------------------------------------------------------------------

echo $(sudo docker image ls)

echo "Performing docker tag and push"
sudo docker tag $REGISTRY_CACHE_URL/saturn_test_app $REGISTRY_CACHE_IMAGE_URL
sudo docker push $REGISTRY_CACHE_IMAGE_URL
echo "Docker push finished"

#--------------------------------------------------------------------------------

echo "Deleting job machine"
api_request "DELETE" "jobs/$JOB_ID/job_machine"
