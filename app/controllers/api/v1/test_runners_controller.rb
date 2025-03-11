module API
  module V1
    class TestRunnersController < APIController
      def index
        test_runners = TestRunner.order("created_at desc")
        authorize test_runners
        render json: test_runners
      rescue StandardError => e
        render(json: { error: e.message }, status: :bad_request)
      end

      def show
        test_runner = TestRunner.find_by_abbreviated_hash(params[:id])
        authorize test_runner

        render json: test_runner.as_json.merge(
          ip_address: RunnerNetwork.new(test_runner.cloud_id).ip_address,
          rsa_key: rsa_key(test_runner)
        )
      rescue StandardError => e
        render(json: { error: e.message }, status: :bad_request)
      end

      private

      def rsa_key(test_runner)
        Base64.strict_encode64(test_runner.rsa_key.private_key_value)
      end
    end
  end
end
