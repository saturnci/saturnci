def draw(routes_name)
  instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
end

Rails.application.routes.draw do
  resources :marketing, only: [] do
    get "home", on: :collection
  end

  root to: "marketing#home"

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  mount ActionCable.server => '/cable'

  get "runs/:id/:partial", to: "runs#show", as: "run"
  get "builds/:id(/:partial)", to: "builds#show", as: "build"

  resources :projects do
    resource :settings do
      resource :general_settings, only: %i(show update)
      resource :project_secret_collection, only: %i(show update)
    end

    resources :builds, only: %i(show create destroy) do
      resources :runs, only: :show do
        get ":partial", to: "runs#show", on: :member, as: "run_detail_content"
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

  draw :admin
  draw :api
end
