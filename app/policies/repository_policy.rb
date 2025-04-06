class RepositoryPolicy < ApplicationPolicy
  def index?
    record.all? { |r| r.user == user }
  end
end
