class RepositoryPolicy < ApplicationPolicy
  def index?
    [record].flatten.all? do |repository|
      user.github_repositories.include?(repository)
    end
  end

  def show?
    user.can_access_repository?(record.repository)
  end

  def update?
    user.can_access_repository?(record.repository)
  end
end
