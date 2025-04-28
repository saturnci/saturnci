class RepositoriesController < ApplicationController
  skip_before_action :authenticate_user_or_404!, only: :index

  def index
    if !user_signed_in?
      skip_authorization
      redirect_to new_user_session_path and return
    end

    if user_signed_in? && current_user.email.blank?
      skip_authorization
      redirect_to new_user_email_path and return
    end

    client = current_user.github_client
    @github_repositories = client.repositories

    loop do
      break if client.last_response.rels[:next].nil?
      @github_repositories.concat client.get(client.last_response.rels[:next].href)
    end

    @repositories = Repository.where(github_repo_full_name: @github_repositories.map(&:full_name))
    authorize @repositories
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
