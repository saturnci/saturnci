namespace :api do
  namespace :v1 do
    resources :runs, only: %w[index show] do
      resources :run_finished_events, only: :create
      resources :system_logs, only: :create
      resource :test_output, only: :create
      resource :json_output, only: :create
      resources :screenshots, only: :create
      resources :run_events, only: :create
      resource :runner, only: :destroy
    end

    resources :runs, only: %w[index show update]
    resource :orphaned_runner_collection, only: :destroy
    resources :test_suite_runs, only: :index
    resources :test_runners, only: %i[index show update]
    resources :test_runner_events, only: :create

    resources :github_events
    resources :github_tokens, only: :create
    resources :job_machine_images, only: :update
    resources :debug_messages, only: :create
  end
end
