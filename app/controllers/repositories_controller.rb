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

    @repositories = current_user.github_repositories.active.order("github_repo_full_name asc")
    authorize @repositories
  end

  def new
    @repository = Repository.new
    authorize @repository

    @github_repositories = current_user.github_client.repositories

    loop do
      break if current_user.github_client.last_response.rels[:next].nil?
      @github_repositories.concat current_user.github_client.get(current_user.github_client.last_response.rels[:next].href)
    end
  end

  def create
    github_account = current_user.github_accounts.first
    repo_full_name = params[:repo_full_name]
    raise "Repository name missing" if repo_full_name.blank?
    repo = github_account.installation_access_octokit_client.get("/repos/#{repo_full_name}")

    repository = Repository.create!(
      github_account:,
      name: repo_full_name,
      github_repo_full_name: repo_full_name
    )
    authorize repository

    redirect_to repositories_path
  end

  def show
    @repository = Repository.find(params[:id])
    authorize @repository

    if @repository.test_suite_runs.any?
      test_suite_run = @repository.test_suite_runs.order("created_at desc").first
      redirect_to TestSuiteRunLinkPath.new(test_suite_run).value
    else
      test_suite_run = TestSuiteRunFromCommitFactory.new(
        TestSuiteRunFromCommitFactory.most_recent_commit(@repository)
      ).test_suite_run

      test_suite_run.repository = @repository
      test_suite_run.save!

      redirect_to TestSuiteRunLinkPath.new(test_suite_run).value
    end
  end
end
