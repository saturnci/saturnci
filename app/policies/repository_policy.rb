class RepositoryPolicy < ApplicationPolicy
  def index?
    record.all? { |r| r.user == user }
  end

  def show?
    record.user == user
  end

  def update?
    record.user == user
  end
end
