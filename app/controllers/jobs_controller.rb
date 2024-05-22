class JobsController < ApplicationController
  def show
    @job = Job.find(params[:id])
    @build = @job.build
    @project = @build.project
    @build_list = BuildList.new(@build, branch_name: params[:branch_name])
    @current_tab_name = params[:partial] || DEFAULT_PARTIAL
  end
end
