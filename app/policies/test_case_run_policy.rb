class TestCaseRunPolicy < ApplicationPolicy
  def show?
    user.can_access_repository?(record.repository)
  end
end
