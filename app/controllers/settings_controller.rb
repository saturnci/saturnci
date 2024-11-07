class SettingsController < ApplicationController
  def index
    @project = Project.find(params[:project_id])
    @project_component = ProjectComponent.new(@project)
  end
end

