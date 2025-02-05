class BuildPolicy < ApplicationPolicy
  def create?
    record.project.user == user
  end

  def show?
    record.project.user == user
  end

  def destroy?
    record.project.user == user
  end
end
