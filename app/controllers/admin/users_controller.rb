module Admin
  class UsersController < ApplicationController
    def index
      @users = User.left_joins(github_accounts: { projects: :test_suite_runs })
                   .select("users.*, MAX(test_suite_runs.created_at) as most_recent_test_run")
                   .group("users.id")
                   .order(Arel.sql("COALESCE(MAX(test_suite_runs.created_at), users.created_at) DESC"))
      authorize :admin, :index?
    end
  end
end
