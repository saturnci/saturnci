module API
  module V1
    class TestRunnersController < APIController
      def index
        test_runners = TestRunner.order("created_at desc").limit(100)
        authorize test_runners
        render json: test_runners
      rescue StandardError => e
        render(json: { error: e.message }, status: :bad_request)
      end

      def show
        test_runner = TestRunner.find_by_abbreviated_hash(params[:id])

        if test_runner.nil?
          skip_authorization

          return render(
            json: { error: "Test runner #{params[:id]} not found" },
            status: :not_found
          )
        end

        authorize test_runner

        render json: test_runner.as_json.merge(
          run_id: test_runner.run&.id,
          ip_address: RunnerNetwork.new(test_runner.cloud_id).ip_address,
          rsa_key: rsa_key(test_runner)
        )
      rescue StandardError => e
        render(json: { error: e.message }, status: :bad_request)
      end

      def update
        test_runner = TestRunner.find_by_abbreviated_hash(params[:id])
        authorize test_runner

        test_runner.terminate_on_completion = params[:terminate_on_completion]
        test_runner.save!

        render json: test_runner.as_json
      end

      def destroy
        test_runner = TestRunner.find_by_abbreviated_hash(params[:id])
        authorize test_runner

        test_runner.destroy!

        head :no_content
      end

      private

      def rsa_key(test_runner)
        Base64.strict_encode64(test_runner.rsa_key.private_key_value)
      end
    end
  end
end
