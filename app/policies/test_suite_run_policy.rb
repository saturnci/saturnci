class TestSuiteRunPolicy < ApplicationPolicy
  def index?
    user.super_admin?
  end

  def create?
    user.can_access_repository?(record.repository)
  end

  def show?
    user.can_access_repository?(record.repository)
  end

  def destroy?
    user.can_access_repository?(record.repository)
  end
end
