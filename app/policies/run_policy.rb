class RunPolicy < ApplicationPolicy
  def index?
    return true if user.super_admin?
    record.all? { |run| run.build.repository.user == user }
  end

  def show?
    return true if user.super_admin?
    record.build.repository.user == user
  end

  def update?
    return true if user.super_admin?
    record.build.repository.user == user
  end

  def destroy?
    return true if user.super_admin?
    record.build.repository.user == user
  end
end
