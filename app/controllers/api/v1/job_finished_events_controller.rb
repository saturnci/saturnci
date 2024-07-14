module API
  module V1
    class JobFinishedEventsController < APIController
      def create
        job = Job.find(params[:job_id])

        ActiveRecord::Base.transaction do
          job.job_events.create!(type: "job_finished")

          if job.build.jobs.all?(&:finished?)
            job.build.update!(finished_at: Time.zone.now)
          end
        end

        head :ok
      end
    end
  end
end
