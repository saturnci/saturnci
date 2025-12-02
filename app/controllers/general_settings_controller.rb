class GeneralSettingsController < ApplicationController
  def show
    @repository = Repository.find(params[:repository_id])
    authorize @repository, :show?

    @repository_component = RepositoryComponent.new(@repository)
  end

  def update
    @repository = Repository.find(params[:repository_id])
    authorize @repository, :update?

    @repository.update!(repository_params)

    flash[:notice] = "Settings saved"

    redirect_to repository_settings_general_settings_path(@repository)
  end

  private

  def repository_params
    params.require(:repository).permit(
      :start_test_suite_runs_automatically_on_git_push,
      :create_github_check_runs_on_pull_requests,
      :concurrency
    )
  end
end
