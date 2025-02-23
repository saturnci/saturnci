require "rails_helper"

describe SaturnCIRunnerAPI::Stream do
  let!(:stream) do
    SaturnCIRunnerAPI::Stream.new(
      "/foo/bar/log",
      "runs/123/system_logs",
      wait_interval: 0
    )
  end

  context "first read" do
    it "sends all the contents" do
      allow(stream).to receive(:log_file_content)
        .and_return(["line 1", "line 2", "line 3"])

      expect(stream).to receive(:send_content)
        .with("line 1\nline 2\nline 3")

      thread = stream.start
      stream.kill
    end
  end
end
