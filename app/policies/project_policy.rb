class ProjectPolicy < ApplicationPolicy
  def show?
    record.user == user
  end
end
