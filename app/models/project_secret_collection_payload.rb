class ProjectSecretCollectionPayload
  attr_reader :project_secrets

  def initialize(attrs, persisted_project_secrets:)
    attrs = attrs
    @persisted_project_secrets = persisted_project_secrets

    @project_secrets = attrs.to_h.map do |_index, project_secret_attributes|
      ProjectSecret.new(project_secret_attributes)
    end
  end

  def touched?(project_secret_key)
    !masked_project_secrets.map(&:key).include?(project_secret_key)
  end

  def masked_project_secrets
    @project_secrets.select do |project_secret|
      project_secret.value == ProjectSecret::MASK_VALUE
    end
  end

  def blank_keys
    @persisted_project_secrets.map(&:key) - @project_secrets.map(&:key)
  end

  def blank_project_secrets
    @project_secrets.select do |project_secret|
      blank_keys.include?(project_secret.key)
    end
  end

  def empty_project_secrets
    @project_secrets.select do |project_secret|
      project_secret.key.blank?
    end
  end

  def touched_keys
    touched_project_secrets.map(&:key)
  end

  def touched_project_secrets
    @project_secrets - blank_project_secrets - empty_project_secrets - masked_project_secrets
  end
end
