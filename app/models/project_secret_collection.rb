class ProjectSecretCollection
  include ActiveModel::Model
  attr_accessor :repository
  attr_accessor :project_secrets

  def project_secrets_attributes=(attributes)
    @payload = ProjectSecretCollectionPayload.new(
      attributes,
      persisted_project_secrets: repository.project_secrets
    )
  end

  def save!
    repository.project_secrets.where(key: @payload.blank_keys).destroy_all
    repository.project_secrets.where(key: @payload.touched_keys).destroy_all
    repository.project_secrets << @payload.touched_project_secrets
  end
end
