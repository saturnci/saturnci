class ProjectSecretCollection
  include ActiveModel::Model
  attr_accessor :project
  attr_accessor :project_secrets

  def project_secrets_attributes=(attributes)
    @project_secrets ||= []

    attributes.each do |_index, project_secret_attributes|
      next if project_secret_attributes["key"].blank? || project_secret_attributes["value"].blank?
      next if project.project_secrets.where(key: project_secret_attributes["key"]).any?
      @project_secrets << ProjectSecret.new(project_secret_attributes)
    end
  end

  def save!
    project.project_secrets << @project_secrets
  end
end
