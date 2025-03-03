class TestSuiteRunPolicy < ApplicationPolicy
  def create?
    record.project.user == user
  end
end
