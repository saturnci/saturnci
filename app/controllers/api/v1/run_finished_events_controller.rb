module API
  module V1
    class RunFinishedEventsController < APIController
      def create
        begin
          run = Run.find(params[:run_id])
          authorize run, :update?

          ActiveRecord::Base.transaction do
            run.finish!

            if run.build.runs.all?(&:finished?)
              Turbo::StreamsChannel.broadcast_update_to(
                "build_status_#{run.build.id}",
                target: "build_status_#{run.build.id}",
                partial: "builds/build_link_content",
                locals: { build: run.build }
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
