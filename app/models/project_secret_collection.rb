class ProjectSecretCollection
  include ActiveModel::Model
  attr_accessor :project
  attr_accessor :project_secrets

  def project_secrets_attributes=(attributes)
    @project_secrets = []

    attributes.each do |_index, project_secret_attributes|
      @project_secrets << ProjectSecret.new(project_secret_attributes)
    end
  end

  def save!
    project_secrets = @project_secrets.reject do |project_secret|
      (project_secret.key.blank? || project_secret.value.blank?) ||
        project_secret.value == ProjectSecret::MASK_VALUE
    end

    ProjectSecret.where(key: project_secrets.map(&:key)).destroy_all

    project.project_secrets << project_secrets
  end
end
