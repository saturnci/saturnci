module SaturnCIRunnerAPI
  class ContentRequest
    def initialize(host:, api_path:, content_type:, content:)
      @host = host
      @api_path = api_path
      @content_type = content_type
      @content = content
    end

    def execute
      command = <<~COMMAND
        curl -s -f -u #{ENV["SATURNCI_API_USERNAME"]}:#{ENV["SATURNCI_API_PASSWORD"]} \
            -X POST \
            -H "Content-Type: #{@content_type}" \
            -d "#{@content}" #{url}
      COMMAND

      system(command)
    end

    private

    def url
      "#{@host}/api/v1/#{@api_path}"
    end
  end
end