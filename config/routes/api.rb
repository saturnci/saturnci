namespace :api do
  namespace :v1 do
    resources :runs, only: %w[index show] do
      resources :run_finished_events, only: :create
      resources :test_reports, only: :create
      resources :system_logs, only: :create
      resource :test_output, only: :create
      resources :run_events, only: :create
      resource :runner, only: :destroy
    end

    resources :jobs, only: %w[index show]
    resources :builds, only: :index

    resources :github_events
    resources :github_tokens, only: :create
    resources :job_machine_images, only: :update
    resources :debug_messages, only: :create
  end
end
