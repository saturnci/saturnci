class RepositoryPolicy < ApplicationPolicy
  def index?
    [record].flatten.all? do |repository|
      user.can_access_repository?(repository)
    end
  end

  def new?
    true
  end

  def create?
    true
  end

  def show?
    user.can_access_repository?(record)
  end

  def update?
    user.can_access_repository?(record)
  end
end
