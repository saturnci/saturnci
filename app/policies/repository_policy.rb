class RepositoryPolicy < ApplicationPolicy
  def index?
    user.github_repositories.include?(record)
  end

  def show?
    user.github_repositories.include?(record)
  end

  def update?
    user.github_repositories.include?(record)
  end
end
