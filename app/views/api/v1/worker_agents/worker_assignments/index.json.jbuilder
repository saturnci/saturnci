json.array! @worker_assignments do |worker_assignment|
  run = worker_assignment.run
  test_suite_run = run.test_suite_run
  project = test_suite_run.project
  user = project.user

  json.extract! worker_assignment, :id, :created_at, :updated_at

  json.run_id run.id
  json.run_order_index run.order_index
  json.test_suite_run_id test_suite_run.id
  json.project_name project.name
  json.branch_name test_suite_run.branch_name
  json.user_id user.id
  json.user_api_token user.api_token
  json.number_of_concurrent_runs project.concurrency
  json.commit_hash test_suite_run.commit_hash
  json.rspec_seed test_suite_run.seed
  json.github_installation_id project.github_account.github_installation_id
  json.github_repo_full_name project.github_repo_full_name

  json.env_vars({})
  json.env_vars do
    project.project_secrets.each do |secret|
      json.set! secret.key, secret.value
    end
  end
end
