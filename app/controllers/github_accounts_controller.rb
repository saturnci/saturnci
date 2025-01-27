class GitHubAccountsController < ApplicationController
  def index
    @github_accounts = current_user.github_accounts
  end

  def show
    @github_account = GitHubAccount.find(params[:id])
  end

  def destroy
    github_account = GitHubAccount.find(params[:id])

    ActiveRecord::Base.transaction do
      github_account.octokit_client.delete_installation(github_account.github_installation_id)
      github_account.destroy!
    end

    redirect_to github_accounts_path
  end
end
