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

    begin
      @repositories = GitHubClient.new(current_user).repositories.active.order("github_repo_full_name asc")
      authorize @repositories
    rescue Octokit::Unauthorized
      skip_authorization
      redirect_to new_user_session_path
    end
  end

  def new
    @repository = Repository.new
    authorize @repository

    begin
      @github_repositories = GitHubClient.new(current_user).octokit_repositories
    rescue Octokit::Unauthorized
      skip_authorization
      sign_out current_user
      redirect_to new_user_session_path
    end
  end

  def create
    github_account = current_user.github_accounts.first
    repo_full_name = params[:repo_full_name]
    raise "Repository name missing" if repo_full_name.blank?

    repository = Repository.create!(
      github_account:,
      name: repo_full_name,
      github_repo_full_name: repo_full_name
    )
    authorize repository

    GitHubClient.new(current_user).invalidate_repositories_cache

    redirect_to repositories_path
  end

  def show
    @repository = Repository.find(params[:id])
    authorize @repository

    if @repository.test_suite_runs.any?
      test_suite_run = @repository.test_suite_runs.order("created_at desc").first
      redirect_to TestSuiteRunLinkPath.new(test_suite_run).value
    end
  end
end
