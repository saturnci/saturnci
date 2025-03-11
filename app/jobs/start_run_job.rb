class StartRunJob < ApplicationJob
  RETRY_INTERVAL_IN_SECONDS = 2
  queue_as :default

  def perform(run_id)
    run = Run.find(run_id)

    ActiveRecord::Base.transaction do
      run.run_events.create!(type: :runner_requested)
      run.provision_test_runner
    end

  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "Run #{run_id} not found. Retrying in #{RETRY_INTERVAL_IN_SECONDS} seconds..."
    retry_job wait: RETRY_INTERVAL_IN_SECONDS.seconds if executions < 10
  end
end
