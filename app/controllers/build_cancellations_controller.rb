class BuildCancellationsController < ApplicationController
  def create
    build = Build.find(params[:build_id])
    authorize build, :destroy?

    build.cancel!

    redirect_to build.project
  end
end
