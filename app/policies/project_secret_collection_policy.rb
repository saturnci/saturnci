class ProjectSecretCollectionPolicy < ApplicationPolicy
  def show?
    record.project_secrets.map(&:project).compact.all? { |project| project.user == user }
  end

  def update?
    record.repository.user == user
  end
end
