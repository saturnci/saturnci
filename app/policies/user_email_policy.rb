class UserEmailPolicy < ApplicationPolicy
  def new?
    record.user == user
  end

  def create?
    record.user == user
  end
end
