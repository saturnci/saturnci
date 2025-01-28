class GeneralSettingsController < ApplicationController
  def show
    @project = Project.find(params[:project_id])
    @project_component = ProjectComponent.new(@project)
  end

  def update
    @project = Project.find(params[:project_id])
    @project.update(project_params)

    flash[:notice] = "Settings saved"

    redirect_to project_settings_general_settings_path(@project)
  end

  private

  def project_params
    params.require(:project).permit(
      :start_builds_automatically_on_git_push,
      :concurrency
    )
  end
end
