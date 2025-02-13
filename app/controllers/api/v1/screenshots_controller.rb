module API
  module V1
    class ScreenshotsController < APIController
      def create
        begin
          run = Run.find(params[:run_id])
          request.body.rewind

          if request.headers["X-Filename"].blank?
            raise "X-Filename header missing"
          end

          ActiveRecord::Base.transaction do
            screenshot = Screenshot.create!(
              build: run.build,
              path: "build-#{run.build.id[0..7]}/#{request.headers["X-Filename"]}"
            )

            spaces_file_upload = SpacesFileUpload.new(
              filename: screenshot.path,
              body: request.body.read,
              content_type: request.headers["Content-Type"]
            )

            spaces_file_upload.put
          end
        rescue StandardError => e
          render(json: { error: e.message }, status: :bad_request)
          return
        end

        head :ok
      end
    end
  end
end
