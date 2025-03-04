class StartRunJob < ApplicationJob
  queue_as :default

  def perform(run_id)
    run = Run.find(run_id)

    transaction do
      run.run_events.create!(type: :runner_requested)
      run.runner_request.execute!
    end
  end
end
