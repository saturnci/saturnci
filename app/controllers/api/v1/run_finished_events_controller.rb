module API
  module V1
    class RunFinishedEventsController < APIController
      def create
        begin
          run = Run.find(params[:run_id])
          authorize run, :update?

          ActiveRecord::Base.transaction do
            run.finish!

            if run.test_suite_run.runs.all?(&:finished?)
              Turbo::StreamsChannel.broadcast_update_to(
                "test_suite_run_link_status_#{run.test_suite_run.id}",
                target: "test_suite_run_link_status_#{run.test_suite_run.id}",
                partial: "test_suite_runs/test_suite_run_link_content",
                locals: { test_suite_run: run.test_suite_run }
              )

              GitHubCheckRun.find_by(build: run.build)&.finish!
            end
          end
        rescue StandardError => e
          render(json: { error: e.message }, status: :bad_request)
          return
        end

        head :ok
      end
    end
  end
end
