class RepositoryPolicy < ApplicationPolicy
  def index?
    record == user.github_repositories
  end

  def show?
    user.github_repositories.include?(record)
  end

  def update?
    user.github_repositories.include?(record)
  end
end
