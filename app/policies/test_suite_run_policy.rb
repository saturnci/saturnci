class TestSuiteRunPolicy < ApplicationPolicy
  def index?
    user.super_admin?
  end

  def create?
    record.repository.user == user
  end

  def show?
    record.repository.user == user
  end

  def destroy?
    record.repository.user == user
  end
end
