class WorkerCollectionPolicy < ApplicationPolicy
  def destroy?
    user.super_admin?
  end
end
