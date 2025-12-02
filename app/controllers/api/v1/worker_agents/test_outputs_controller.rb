require "base64"

module API
  module V1
    module WorkerAgents
      class TestOutputsController < WorkerAgentsAPIController
      TAB_NAME = "test_output"

        def create
          run = Run.find(params[:run_id])
          new_content = Base64.decode64(request.body.read).force_encoding('UTF-8')

          Run.connection.execute(
            Run.sanitize_sql([
              "UPDATE runs SET test_output = COALESCE(test_output, '') || ? WHERE id = ?",
              new_content,
              run.id
            ])
          )

          Streaming::RunOutputStream.new(run: run.reload, tab_name: TAB_NAME).broadcast
          head :ok
        end
      end
    end
  end
end
