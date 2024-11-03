class ProjectSecretCollection
  include ActiveModel::Model
  attr_accessor :project
  attr_accessor :project_secrets

  def project_secrets_attributes=(attributes)
    project.project_secrets ||= []

    attributes.each do |_index, project_secret_attributes|
      next if project_secret_attributes["key"].blank? || project_secret_attributes["value"].blank?
      next if project.project_secrets.where(key: project_secret_attributes["key"]).any?
      project.project_secrets.build(project_secret_attributes)
    end
  end

  def save!
    project.save!
  end
end
