class StartRunJob < ApplicationJob
  queue_as :default

  def perform(run_id)
    Rails.logger.info "Starting run #{run_id}..."
    run = Run.find(run_id)

    ActiveRecord::Base.transaction do
      run.run_events.create!(type: :runner_requested)

      Rails.logger.info "Requesting runner for run #{run_id}..."
      run.runner_request.execute!
      Rails.logger.info "Runner requested for run #{run_id}."
    end
  end
end
