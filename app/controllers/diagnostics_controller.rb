class DiagnosticsController < ApplicationController
  def index
    @project = Project.find(params[:project_id])
    @project_component = ProjectComponent.new(@project)
    authorize @project, :show?

    @limit = 100
    @all_github_events = GitHubEvent.where(project: @project).order("created_at desc")
    @github_events = @all_github_events.limit(@limit)
  end
end
