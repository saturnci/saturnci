class RunPolicy < ApplicationPolicy
  def index?
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
