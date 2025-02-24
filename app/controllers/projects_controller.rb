class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy ]

  def index
    @projects = current_user.projects

    if @projects.count == 1
      redirect_to project_path(@projects.first)
    end
  end

  def show
    authorize @project

    if @project.builds.any?
      build = @project.builds.order("created_at desc").first
      redirect_to TestSuiteRunLinkPath.new(build).value
    elsif @project.builds.with_deleted.empty?
      build = BuildFromCommitFactory.new(
        BuildFromCommitFactory.most_recent_commit(@project)
      ).build

      build.project = @project
      build.save!

      redirect_to TestSuiteRunLinkPath.new(build).value
    end
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to project_url(@project), notice: "Project was successfully created." }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name)
  end
end
