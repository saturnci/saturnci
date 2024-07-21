module API
  module V1
    class JobFinishedEventsController < APIController
      def create
        job = Job.find(params[:job_id])

        ActiveRecord::Base.transaction do
          job.job_events.create!(type: "job_finished")

          if job.build.jobs.all?(&:finished?)
            Turbo::StreamsChannel.broadcast_update_to(
              "build_status_#{job.build.id}",
              target: "build_status_#{job.build.id}",
              partial: "builds/list_item",
              locals: { build: job.build }
            )
          end
        end

        head :ok
      end
    end
  end
end
