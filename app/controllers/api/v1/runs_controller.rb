module API
  module V1
    class RunsController < APIController
      def index
        @runs = Run.running
        render "index", formats: [:json]
      end

      def show
        run = Run.find_by_abbreviated_hash(params[:id])

        render json: run.as_json.merge(
          ip_address: RunnerNetwork.new(run.runner_id).ip_address,
          rsa_key: rsa_key(run)
        )
      end

      def update
        run = Run.find_by_abbreviated_hash(params[:id])
        run.terminate_on_completion = params[:terminate_on_completion]
        run.save!

        render json: run.as_json
      end

      private

      def rsa_key(run)
        return unless File.exist?(run.runner_rsa_key_path.to_s)
        Base64.encode64(File.read(run.runner_rsa_key_path.to_s)).strip
      end
    end
  end
end
