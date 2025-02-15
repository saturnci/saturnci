class RunPolicy < ApplicationPolicy
  def show?
    record.build.project.user == user
  end

  def update?
    record.build.project.user == user
  end

  def destroy?
    record.build.project.user == user
  end
end
