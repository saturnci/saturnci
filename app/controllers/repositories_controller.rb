class RepositoriesController < ApplicationController
  def index
    @repositories = current_user.repositories
    authorize @repositories
  end
end
