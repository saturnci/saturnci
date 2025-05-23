def draw(routes_name)
  instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
end

Rails.application.routes.draw do
  get "silliness", to: "silliness#index"

  get "user_emails/new"
  get "user_emails/create"
  get "saturnci_github_app_authorizations/new"
  root to: "repositories#index"

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  mount ActionCable.server => '/cable'

  resources :builds, only: [] do
    resources :test_case_runs, only: :index
  end

  get "runs/:id/:partial", to: "runs#show", as: "run"
  get "builds/:id(/:partial)", to: "builds#show", as: "build"

  resources :test_suite_runs, only: :create

  resources :repositories do
    resource :settings do
      resource :general_settings, only: %i(show update)
      resource :project_secret_collection, only: %i(show update)
    end

    resources :test_suite_runs, only: %i(index show create destroy) do
      resources :runs, only: :show do
        get ":partial", to: "runs#show", on: :member, as: "run_detail_content"
      end

      get ":partial", to: "builds#show", on: :member, as: "build_detail_content"
    end

    resources :builds, only: %i(index show create destroy) do
      resources :runs, only: :show do
        get ":partial", to: "runs#show", on: :member, as: "run_detail_content"
      end

      get ":partial", to: "builds#show", on: :member, as: "build_detail_content"
    end

    resources :test_case_runs, only: :show
  end

  resources :projects do
    resource :settings do
      resource :general_settings, only: %i(show update)
      resource :project_secret_collection, only: %i(show update)
    end

    resources :test_suite_runs, only: %i(index show create destroy) do
      resources :runs, only: :show do
        get ":partial", to: "runs#show", on: :member, as: "run_detail_content"
      end

      get ":partial", to: "builds#show", on: :member, as: "build_detail_content"
    end

    resources :builds, only: %i(index show create destroy) do
      resources :runs, only: :show do
        get ":partial", to: "runs#show", on: :member, as: "run_detail_content"
      end

      get ":partial", to: "builds#show", on: :member, as: "build_detail_content"
    end

    resources :test_case_runs, only: :show

    get "billing(/:year(/:month))", to: "billing#index", as: "billing"
  end

  resources :github_accounts do
    resources :project_integrations, only: %i(new create)
  end

  resources :test_suite_reruns, only: :create
  resources :test_suite_run_cancellations, only: :create
  resources :user_emails, only: %i(new create)

  draw :admin
  draw :api
end
