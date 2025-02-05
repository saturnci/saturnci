class ProjectSecretCollectionPolicy < ApplicationPolicy
  def show?
    record.project_secrets.map(&:project).compact.all? { |project| project.user == user }
  end

  def update?
    record.project.user == user
  end
end
