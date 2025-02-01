class GitHubAccountsController < ApplicationController
  skip_before_action :authenticate_user_or_404!, only: :index

  def index
    if user_signed_in?
      @github_accounts = current_user.github_accounts
      authorize @github_accounts
    else
      redirect_to new_user_session_path
    end
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
