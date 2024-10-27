class BuildCancellationsController < ApplicationController
  def create
    build = Build.find(params[:build_id])
    build.cancel!

    redirect_to build.project
  end
end
