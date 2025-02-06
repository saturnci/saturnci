class TestCaseRunPolicy < ApplicationPolicy
  def show?
    record.project.user == user
  end
end
