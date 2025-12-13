class TaskPolicy < ApplicationPolicy
  def index?
    return true if user.super_admin?
    record.all? { |task| task.test_suite_run.repository.user == user }
  end

  def show?
    return true if user.super_admin?
    record.test_suite_run.repository.user == user
  end

  def update?
    return true if user.super_admin?
    record.test_suite_run.repository.user == user
  end

  def destroy?
    return true if user.super_admin?
    record.test_suite_run.repository.user == user
  end
end
