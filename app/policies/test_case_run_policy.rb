class TestCaseRunPolicy < ApplicationPolicy
  def show?
    user.github_repositories.include?(record.repository)
  end
end
