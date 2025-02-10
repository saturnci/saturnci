class GitHubAccountPolicy < ApplicationPolicy
  def new?
    true
  end

  def create?
    true
  end

  def index?
    record.all? do |github_account|
      github_account.user == user
    end
  end

  def show?
    record.user == user
  end

  def destroy?
    record.user == user
  end
end
