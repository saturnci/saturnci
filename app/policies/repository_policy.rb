class RepositoryPolicy < ApplicationPolicy
  def index?
    [record].flatten.all? do |repository|
      user.github_repositories.include?(repository)
    end
  end

  def new?
    true
  end

  def create?
    user.github_repositories.include?(record)
  end

  def show?
    user.github_repositories.include?(record)
  end

  def update?
    user.github_repositories.include?(record)
  end
end
