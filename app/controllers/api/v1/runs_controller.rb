module API
  module V1
    class RunsController < APIController
      def index
        @runs = Run.running
        authorize @runs

        render "index", formats: [:json]
      rescue StandardError => e
        render(json: { error: e.message }, status: :bad_request)
      end

      def show
        run = Run.find_by_abbreviated_hash(params[:id])
        authorize run

        render json: run.as_json.merge(
          ip_address: RunnerNetwork.new(run.runner_id).ip_address,
          rsa_key: rsa_key(run)
        )
      rescue StandardError => e
        render(json: { error: e.message }, status: :bad_request)
      end

      def update
        run = Run.find_by_abbreviated_hash(params[:id])
        authorize run

        run.terminate_on_completion = params[:terminate_on_completion]
        run.save!

        render json: run.as_json
      end

      private

      def rsa_key(run)
        Base64.strict_encode64(run.test_runner.rsa_key.private_key_value)
      end
    end
  end
end
