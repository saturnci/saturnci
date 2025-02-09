module API
  module V1
    class RunFinishedEventsController < APIController
      def create
        run = Run.find(params[:run_id])

        ActiveRecord::Base.transaction do
          run.finish!

          if run.build.runs.all?(&:finished?)
            Turbo::StreamsChannel.broadcast_update_to(
              "build_status_#{run.build.id}",
              target: "build_status_#{run.build.id}",
              partial: "builds/build_link_content",
              locals: { build: run.build }
            )
          end
        end

        head :ok
      end
    end
  end
end
