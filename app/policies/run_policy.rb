class RunPolicy < ApplicationPolicy
  def index?
    return true if user.admin?
    record.all? { |run| run.build.project.user == user }
  end

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
