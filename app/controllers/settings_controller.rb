class SettingsController < ApplicationController
  def show
    @repository = Repository.find(params[:repository_id])
    @repository_component = RepositoryComponent.new(@repository)
  end
end

