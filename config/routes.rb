Rails.application.routes.draw do
  root to: "projects#index"

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  mount ActionCable.server => '/cable'

  namespace :admin do
    root "admin#index"

    resources :github_events, only: :index
    resources :users, only: :index
    resources :user_impersonations, only: :create
  end

  get "jobs/:id/:partial", to: "jobs#show", as: "job"
  get "builds/:id(/:partial)", to: "builds#show", as: "build"

  resources :projects do
    resources :settings, only: :index
    resource :project_secret_collection, only: %i(show create destroy)

    resources :builds, only: %i(show create destroy) do
      resources :jobs, only: :show do
        get ":partial", to: "jobs#show", on: :member, as: "job_detail_content"
      end

      get ":partial", to: "builds#show", on: :member, as: "build_detail_content"
    end

    get "billing(/:year(/:month))", to: "billing#index", as: "billing"
  end

  resources :saturn_installations do
    resources :project_integrations, only: %i(new create)
  end

  resources :rebuilds, only: :create
  resources :build_cancellations, only: :create

  namespace :api do
    namespace :v1 do
      resources :jobs, only: %w[index show] do
        resources :system_logs, only: :create
        resources :test_reports, only: :create
        resources :run_finished_events, only: :create
        resource :ssh_key, only: :show
      end

      resources :runs, only: %w[index show] do
        resource :test_output, only: :create
        resources :run_events, only: :create
        resource :runner, only: :destroy
      end

      resources :builds, only: :index

      resources :github_events
      resources :github_tokens, only: :create
      resources :job_machine_images, only: :update
      resources :debug_messages, only: :create
    end
  end
end
