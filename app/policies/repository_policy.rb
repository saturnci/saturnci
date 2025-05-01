class RepositoryPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.user == user
  end

  def update?
    record.user == user
  end
end
