class SuperviseTestRunnersJob < ApplicationJob
  queue_as :default

  def perform
    Run.assign_unassigned
  end
end
