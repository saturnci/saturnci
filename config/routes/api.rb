namespace :api do
  namespace :v1 do
    resources :github_events
    resources :job_machine_images, only: :update
    resources :debug_messages, only: :create

    # CLI endpoints
    resources :runs, only: %i[index show]
    resources :workers, only: %i[index show update destroy]
    resources :test_suite_runs, only: %i[index show create]
    resource :worker_collection, only: :destroy

    namespace :worker_agents do
      resources :runs, only: [] do
        resources :run_finished_events, only: :create
        resources :system_logs, only: :create
        resource :test_output, only: :create
        resource :json_output, only: :create
        resources :test_failure_screenshots, only: :create
        resources :run_events, only: :create
        resource :runner, only: :destroy
      end

      resources :workers, only: [] do
        resources :worker_events, only: :create
        resources :worker_assignments, only: :index
      end

      resources :github_tokens, only: :create
      resources :test_suite_runs, only: :update
    end
  end
end
