class ProjectSecretCollection
  include ActiveModel::Model
  attr_accessor :project
  attr_accessor :project_secrets

  def project_secrets_attributes=(attributes)
    @project_secrets = []

    attributes.each do |_index, secret_params|
      next if secret_params["key"].blank? || secret_params["value"].blank?
      next if project.project_secrets.where(key: secret_params["key"]).any?
      project_secrets << ProjectSecret.new(secret_params)
    end
  end

  def save!
    ActiveRecord::Base.transaction do
      project_secrets.each do |project_secret|
        project_secret.project = project
        project_secret.save!
      end
    end
  end
end
