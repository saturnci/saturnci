class ProjectPolicy < ApplicationPolicy
  def show?
    record.user == user
  end

  def update?
    record.user == user
  end
end
