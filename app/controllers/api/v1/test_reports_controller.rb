module API
  module V1
    class TestReportsController < APIController
      def create
        run = Run.find(params[:run_id])
        authorize run, :update?

        request.body.rewind
        run.update!(test_report: request.body.read)

        head :ok
      end
    end
  end
end
