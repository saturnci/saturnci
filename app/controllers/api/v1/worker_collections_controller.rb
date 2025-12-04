module API
  module V1
    class WorkerCollectionsController < APIController
      def destroy
        authorize :worker_collection, :destroy?
        Worker.all.select { |worker| worker.status != "Finished" && worker.status != "Running" }.each(&:destroy)
        head :no_content
      end
    end
  end
end
