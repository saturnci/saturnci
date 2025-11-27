class TestSuiteRunPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    user.super_admin? || user.can_access_repository?(record.repository)
  end

  def show?
    user.super_admin? || user.can_access_repository?(record.repository)
  end

  def destroy?
    user.super_admin? || user.can_access_repository?(record.repository)
  end

  def update?
    user.super_admin? || user.can_access_repository?(record.repository)
  end
end
