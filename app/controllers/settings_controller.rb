class SettingsController < ApplicationController
  def show
    @project = Project.find(params[:project_id])
    @project_component = ProjectComponent.new(@project)
  end
end

