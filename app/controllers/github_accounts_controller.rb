class GitHubAccountsController < ApplicationController
  skip_before_action :authenticate_user_or_404!, only: :index

  def index
    if user_signed_in?
      if current_user.email.present?
        @github_accounts = current_user.github_accounts
        authorize @github_accounts
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
    @github_account = GitHubAccount.find(params[:id])
    authorize @github_account
  end

  def destroy
    github_account = GitHubAccount.find(params[:id])
    authorize github_account

    ActiveRecord::Base.transaction do
      github_account.octokit_client.delete_installation(github_account.github_installation_id)
      github_account.destroy!
    end

    redirect_to github_accounts_path
  end
end
