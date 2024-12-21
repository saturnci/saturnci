class BuildsController < ApplicationController
  def create
    @project = Project.find(params[:project_id])
    build = Build.new(project: @project)
    build.start!

    redirect_to build
  end

  def show
    @build = Build.find(params[:id])

    @build_component = BuildComponent.new(
      build: @build,
      current_tab_name: params[:partial],
      branch_name: params[:branch_name],
      statuses: params[:statuses],
      clear: params[:clear]
    )
  end

  def destroy
    build = Build.find(params[:id])

    begin
      build.delete_runners
    rescue DropletKit::Error => e
      if e.message.include?("404")
        Rails.logger.error "Failed to delete runner: #{e.message}"
      else
        raise
      end
    end

    build.destroy
    redirect_to project_path(build.project)
  end
end
