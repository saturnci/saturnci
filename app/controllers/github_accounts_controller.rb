class GitHubAccountsController < ApplicationController
  def index
    @github_accounts = current_user.github_accounts
  end

  def destroy
    github_account = GitHubAccount.find(params[:id])
    github_account.destroy!

    redirect_to github_accounts_path
  end
end
