require "base64"

module SaturnCIRunnerAPI
  class Stream
    def initialize(log_file_path, api_path)
      @log_file_path = log_file_path
      @api_path = api_path
    end

    def start
      Thread.new do
        most_recent_total_line_count = 0

        while true
          all_lines = File.readlines(@log_file_path)
          newest_content = all_lines[most_recent_total_line_count..-1].join("\n")

          SaturnCIRunnerAPI::ContentRequest.new(
            host: ENV["HOST"],
            api_path: @api_path,
            content_type: "text/plain",
            content: Base64.encode64(newest_content + "\n")
          ).execute

          most_recent_total_line_count = all_lines.count

          sleep(1)
        end
      end
    end
  end
end
