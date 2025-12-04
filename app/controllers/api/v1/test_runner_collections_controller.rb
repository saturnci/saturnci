module API
  module V1
    class TestRunnerCollectionsController < APIController
      def destroy
        authorize :test_runner_collection, :destroy?
        Worker.all.select { |worker| worker.status != "Finished" && worker.status != "Running" }.each(&:destroy)
        head :no_content
      end
    end
  end
end
