class TestSuiteRunPolicy < ApplicationPolicy
  def index?
    user.super_admin?
  end

  def create?
    user.github_repositories.include?(record.repository)
  end

  def show?
    user.github_repositories.include?(record.repository)
  end

  def destroy?
    user.github_repositories.include?(record.repository)
  end
end
