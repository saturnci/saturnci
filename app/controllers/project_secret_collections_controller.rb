class ProjectSecretCollectionsController < ApplicationController
  NUMBER_OF_EMPTY_PROJECT_SECRET_FIELDS = 10

  def show
    @repository = Repository.find(params[:repository_id])
    @project_secret_collection = ProjectSecretCollection.new
    @project_secret_collection.project_secrets = @repository.project_secrets.to_a

    NUMBER_OF_EMPTY_PROJECT_SECRET_FIELDS.times do
      @project_secret_collection.project_secrets << ProjectSecret.new
    end

    @repository_component = RepositoryComponent.new(@repository)
    authorize @project_secret_collection
  end

  def update
    @repository = Repository.find(params[:repository_id])

    @project_secret_collection = ProjectSecretCollection.new
    @project_secret_collection.repository = @repository
    @project_secret_collection.project_secrets_attributes = project_secret_collection_params[:project_secrets_attributes]

    authorize @project_secret_collection
    @project_secret_collection.save!

    redirect_to repository_settings_project_secret_collection_path(@repository)
  end

  private

  def project_secret_collection_params
    params.require(:project_secret_collection)
      .permit(project_secrets_attributes: [:key, :value])
  end
end
