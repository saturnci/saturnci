module Admin
  class UsersController < ApplicationController
    def index
      @users = User.joins(github_accounts: { projects: :test_suite_runs })
                   .select("users.*, MAX(test_suite_runs.created_at) as most_recent_test_run")
                   .group("users.id")
                   .order("most_recent_test_run DESC NULLS LAST")

      # Include users with no test suite runs at the end
      users_with_runs = @users
      users_without_runs = User.left_joins(github_accounts: { projects: :test_suite_runs })
                              .where(test_suite_runs: { id: nil })
                              .order("created_at desc")
      @users = users_with_runs + users_without_runs
      authorize :admin, :index?
    end
  end
end
