class ProjectSecretCollection
  include ActiveModel::Model
  attr_accessor :project
  attr_accessor :project_secrets

  def project_secrets_attributes=(attributes)
    @project_secrets ||= []

    attributes.each do |_index, project_secret_attributes|
      @project_secrets << ProjectSecret.new(project_secret_attributes)
    end
  end

  def delete_blank_secrets!
    project.project_secrets.each do |project_secret|
      if !@project_secrets.map(&:key).include?(project_secret.key)
        project_secret.destroy!
      end
    end
  end

  def save!
    project_secrets = @project_secrets.reject do |project_secret|
      project_secret.key.blank? || project_secret.value.blank?
    end.reject do |project_secret|
      project.project_secrets.where(key: project_secret.key).any?
    end

    project.project_secrets << project_secrets
  end
end
