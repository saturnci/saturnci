require "aws-sdk-s3"

module API
  module V1
    class ScreenshotsController < APIController
      def create
        run = Run.find(params[:run_id])
        request.body.rewind

        spaces_file_upload = SpacesFileUpload.new(
          filename: request.headers["X-Filename"],
          body: request.body.read,
          content_type: request.headers["Content-Type"]
        )

        spaces_file_upload.put

        head :ok
      end
    end
  end
end
