module API
  module V1
    class TestRunnerCollectionsController < APIController
      def destroy
        authorize :test_runner_collection, :destroy?
        TestRunner.all.select { |tr| tr.status != "Finished" }.each(&:destroy)
        head :no_content
      end
    end
  end
end
