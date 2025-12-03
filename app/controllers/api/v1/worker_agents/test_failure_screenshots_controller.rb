module API
  module V1
    module WorkerAgents
      class TestFailureScreenshotsController < WorkerAgentsAPIController
        def create
          run = Run.find(params[:run_id])
          screenshot_file = ScreenshotFile.new(path: params[:file].original_filename)
          test_case_run = screenshot_file.matching_test_case_run(run)

          TestFailureScreenshot.create!(
            test_case_run: test_case_run,
            path: params[:file].original_filename
          )

          head :ok
        end
      end
    end
  end
end
