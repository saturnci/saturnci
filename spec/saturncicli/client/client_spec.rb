require_relative "../../../lib/saturncicli/client"
require_relative "../helpers/authentication_helper"
require_relative "../helpers/api_helper"

describe "client" do
  describe "jobs" do
    before do
      AuthenticationHelper.stub_authentication_request


      body = [
        {
          "id" => "cdbe84c7",
          "build_id" => "3cbe1b26",
          "created_at" => "2024-02-28 15:38:06",
          "status" => "Passed",
          "build_commit_message" => "Did stuff",
        },
        {
          "id" => "6882b373",
          "build_id" => "56d2a863",
          "created_at" => "2024-02-28 15:36:18",
          "status" => "Passed",
          "build_commit_message" => "Did other stuff",
        },
        {
          "id" => "4c304b55",
          "build_id" => "7c8dd048",
          "created_at" => "2024-02-28 01:57:05",
          "status" => "Passed",
          "build_commit_message" => "Did yet other stuff",
        },
        {
          "id" => "4cdfb661",
          "build_id" => "65a7e250",
          "created_at" => "2024-02-28 01:52:07",
          "status" => "Passed",
          "build_commit_message" => "Did similar but different stuff",
        }
      ].to_json

      APIHelper.stub_body("api/v1/jobs", body)
    end

    let!(:client) do
      SaturnCICLI::Client.new(
        username: ENV["SATURNCI_API_USERNAME"],
        password: ENV["SATURNCI_API_PASSWORD"]
      )
    end

    it "shows jobs" do
      expected_output = <<~OUTPUT
      ID        Created              Build status  Build ID  Build commit message
      cdbe84c7  2024-02-28 15:38:06  Passed        3cbe1b26  Did stuff
      6882b373  2024-02-28 15:36:18  Passed        56d2a863  Did other stuff
      4c304b55  2024-02-28 01:57:05  Passed        7c8dd048  Did yet other stuff
      4cdfb661  2024-02-28 01:52:07  Passed        65a7e250  Did similar but different stuff
      OUTPUT

      expect {
        client.execute("jobs")
      }.to output(expected_output).to_stdout
    end
  end
end
