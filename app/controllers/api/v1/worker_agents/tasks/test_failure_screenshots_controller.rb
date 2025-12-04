module API
  module V1
    module WorkerAgents
      module Tasks
        class TestFailureScreenshotsController < WorkerAgentsAPIController
          def create
            begin
              task = Task.find(params[:task_id])
              filename = request.headers["X-Filename"]
              request.body.rewind

              ActiveRecord::Base.transaction do
                screenshot_file = ScreenshotFile.new(path: filename)
                test_case_run = screenshot_file.matching_test_case_run(task)

                test_failure_screenshot = TestFailureScreenshot.create!(
                  test_case_run:,
                  path: filename
                )

                spaces_file_upload = SpacesFileUpload.new(
                  filename: test_failure_screenshot.path,
                  body: request.body.read,
                  content_type: request.headers["Content-Type"]
                )

                spaces_file_upload.put
              end

              head :ok
            rescue StandardError => e
              render(json: { error: e.message }, status: :bad_request)
              return
            end
          end
        end
      end
    end
  end
end
