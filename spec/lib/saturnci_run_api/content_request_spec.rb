require "rails_helper"

describe SaturnCIRunnerAPI::ContentRequest do
  let!(:content_request) do
    SaturnCIRunnerAPI::ContentRequest.new(
      host: "http://localhost:3000",
      api_path: "runs/123/system_logs",
      content_type: "text/plain",
      content: "test content"
    )
  end

  it "works" do
    content_request.execute
  end
end
