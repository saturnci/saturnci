class BuildPolicy < ApplicationPolicy
  def update?
    record.project.user == user
  end
end
