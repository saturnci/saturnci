module API
  module V1
    class OrphanedRunnerCollectionsController < APIController
      def destroy
        authorize :infrastructure_resource, :destroy?
        Runner.destroy_orphaned
      rescue StandardError => e
        render(json: { error: e.message }, status: :bad_request)
      end
    end
  end
end
