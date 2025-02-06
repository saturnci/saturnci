module SaturnCIRunnerAPI
  class FileContentRequest
    def initialize(host:, api_path:, content_type:, file_path:)
      @host = host
      @api_path = api_path
      @content_type = content_type
      @file_path = file_path
    end

    def execute
      command = <<~COMMAND
        curl -s -f -u #{ENV["USER_ID"]}:#{ENV["USER_API_TOKEN"]} \
            -X POST \
            -H "Content-Type: #{@content_type}" \
            --data-binary "@#{@file_path}" #{url}
      COMMAND

      puts command
      system(command)
    end

    private

    def url
      "#{@host}/api/v1/#{@api_path}"
    end
  end
end
