class GitHubAccountPolicy < ApplicationPolicy
  def show?
    record.user == user
  end
end
