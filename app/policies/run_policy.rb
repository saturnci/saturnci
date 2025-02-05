class RunPolicy < ApplicationPolicy
  def show?
    record.build.project.user == user
  end
end
