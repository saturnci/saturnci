require "jwt"
require "octokit"

class ProjectIntegrationsController < ApplicationController
  def new
    @github_account = GitHubAccount.find(params[:github_account_id])
    authorize @github_account

    @repositories = []
    page = 0

    begin
      page += 1
      current_page_repositories = @github_account.installation_access_octokit_client.get("/installation/repositories", page: page)
      @repositories += current_page_repositories.repositories
    end while current_page_repositories.total_count > @repositories.size
  end

  def create
    @github_account = GitHubAccount.find(params[:github_account_id])
    authorize @github_account

    repo_full_name = params[:repo_full_name]
    repo = @github_account.installation_access_octokit_client.get("/repos/#{repo_full_name}")

    project = current_user.projects.create!(
      github_account: @github_account,
      name: repo_full_name,
      github_repo_full_name: repo_full_name
    )

    redirect_to project
  end
end
