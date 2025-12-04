module API
  module V1
    class TestRunnersController < APIController
      def index
        workers = Worker.order("created_at desc").limit(100)
        authorize workers
        render json: workers
      rescue StandardError => e
        render(json: { error: e.message }, status: :bad_request)
      end

      def show
        worker = Worker.find_by_abbreviated_hash(params[:id])

        if worker.nil?
          skip_authorization

          return render(
            json: { error: "Worker #{params[:id]} not found" },
            status: :not_found
          )
        end

        authorize worker

        render json: worker.as_json.merge(
          run_id: worker.run&.id,
          ip_address: RunnerNetwork.new(worker.cloud_id).ip_address,
          rsa_key: rsa_key(worker)
        )
      rescue StandardError => e
        render(json: { error: e.message }, status: :bad_request)
      end

      def update
        worker = Worker.find_by_abbreviated_hash(params[:id])
        authorize worker

        worker.terminate_on_completion = params[:terminate_on_completion]
        worker.save!

        render json: worker.as_json
      end

      def destroy
        worker = Worker.find_by_abbreviated_hash(params[:id])
        authorize worker

        worker.destroy!

        head :no_content
      end

      private

      def rsa_key(worker)
        Base64.strict_encode64(worker.rsa_key.private_key_value)
      end
    end
  end
end
