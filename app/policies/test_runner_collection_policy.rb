class TestRunnerCollectionPolicy < ApplicationPolicy
  def destroy?
    user.super_admin?
  end
end