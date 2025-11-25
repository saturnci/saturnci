module API
  module V1
    class TestRunnerCollectionsController < APIController
      def destroy
        authorize :test_runner_collection, :destroy?
        TestRunner.all.select { |tr| tr.status != "Finished" && tr.status != "Running" }.each(&:destroy)
        head :no_content
      end
    end
  end
end
