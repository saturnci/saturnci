test_suite_run = @task.test_suite_run
repository = test_suite_run.repository

json.github_repo_full_name repository.github_repo_full_name
json.branch_name test_suite_run.branch_name
json.commit_hash test_suite_run.commit_hash
json.github_installation_id repository.github_account.github_installation_id
json.rspec_seed test_suite_run.seed
json.run_order_index @task.order_index
json.number_of_concurrent_runs repository.concurrency

json.env_vars({})
json.env_vars do
  repository.project_secrets.each do |secret|
    json.set! secret.key, secret.value
  end
end
