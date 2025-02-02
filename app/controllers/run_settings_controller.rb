class RunSettingsController < ApplicationController
  def update
    @run = Run.find(params[:run_id])
    @run.update!(terminate_on_completion: params[:run][:terminate_on_completion])

    flash[:notice] = "Settings updated"
    redirect_to run_path(@run, "settings")
  end
end
