json.array! @runs do |run|
  json.extract! run, :id, :build_id, :created_at, :status
  json.build_commit_message run.build.commit_message
end
