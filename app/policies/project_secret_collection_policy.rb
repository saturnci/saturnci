class ProjectSecretCollectionPolicy < ApplicationPolicy
  def show?
    return true if user.super_admin?
    record.project_secrets.map(&:project).compact.all? { |project| project.user == user }
  end

  def update?
    return true if user.super_admin?
    record.repository.user == user
  end
end
