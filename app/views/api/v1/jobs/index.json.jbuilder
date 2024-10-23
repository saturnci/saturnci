json.array! @jobs do |job|
  json.extract! job, :id, :build_id, :created_at, :status
  json.build_commit_message job.build.commit_message
end
