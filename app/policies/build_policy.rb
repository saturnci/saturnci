class BuildPolicy < ApplicationPolicy
  def index?
    user.super_admin?
  end

  def create?
    record.project.user == user
  end

  def show?
    record.project.user == user
  end

  def destroy?
    record.project.user == user
  end
end
