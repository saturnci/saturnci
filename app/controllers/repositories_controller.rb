class RepositoriesController < ApplicationController
  skip_before_action :authenticate_user_or_404!, only: :index

  def index
    if user_signed_in?
      if current_user.email.present?
        @repositories = current_user.repositories
        authorize @repositories
      else
        skip_authorization
        redirect_to new_user_email_path
      end
    else
      skip_authorization
      redirect_to new_user_session_path
    end
  end

  def show
    @repository = Repository.find(params[:id])
    authorize @repository

    if @repository.test_suite_runs.any?
      test_suite_run = @repository.test_suite_runs.order("created_at desc").first
      redirect_to TestSuiteRunLinkPath.new(test_suite_run).value
    elsif @repository.test_suite_runs.with_deleted.empty?
      test_suite_run = TestSuiteRunFromCommitFactory.new(
        TestSuiteRunFromCommitFactory.most_recent_commit(@repository)
      ).test_suite_run

      test_suite_run.repository = @repository
      test_suite_run.save!

      redirect_to TestSuiteRunLinkPath.new(test_suite_run).value
    end
  end
end
