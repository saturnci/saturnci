#!/bin/bash
set -e

WORKER_ID=$1
WORKER_ACCESS_TOKEN=$2
TASK_ID=$3

kubectl --context do-nyc2-saturnci-workers-cluster run "nova-${TASK_ID}" \
  --image=registry.digitalocean.com/saturnci/worker-agent:latest \
  --restart=Never \
  --env="SATURNCI_API_HOST=https://app.saturnci.com" \
  --env="WORKER_ID=${WORKER_ID}" \
  --env="WORKER_ACCESS_TOKEN=${WORKER_ACCESS_TOKEN}" \
  -- ruby -e '
require "net/http"
require "uri"
require "json"

uri = URI("#{ENV["SATURNCI_API_HOST"]}/api/v1/worker_agents/workers/#{ENV["WORKER_ID"]}/worker_events")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

req = Net::HTTP::Post.new(uri)
req.basic_auth(ENV["WORKER_ID"], ENV["WORKER_ACCESS_TOKEN"])
req["Content-Type"] = "application/json"
req.body = {type: "assignment_acknowledged"}.to_json

res = http.request(req)
puts "Response: #{res.code}"
'

echo "Pod created. Check with: kubectl --context do-nyc2-saturnci-workers-cluster logs nova-${TASK_ID}"
