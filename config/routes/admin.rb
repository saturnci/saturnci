namespace :admin do
  root "admin#index"

  resources :github_events, only: :index
  resources :users, only: :index
  resources :user_impersonations, only: :create
  resources :test_runner_assignments, only: :index
end
