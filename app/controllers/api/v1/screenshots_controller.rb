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

          spaces_file_upload = SpacesFileUpload.new(
            filename: "screenshots/#{run.build.id}/request.headers["X-Filename"]",
            body: request.body.read,
            content_type: request.headers["Content-Type"]
          )

          spaces_file_upload.put
        rescue StandardError => e
          render(json: { error: e.message }, status: :bad_request)
          return
        end

        head :ok
      end
    end
  end
end
