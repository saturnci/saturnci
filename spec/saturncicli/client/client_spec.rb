require_relative "../../../lib/saturncicli/client"
require_relative "../../../lib/saturncicli/credential"
require_relative "../helpers/authentication_helper"
require_relative "../helpers/api_helper"

describe "client" do
  let!(:credential) do
    SaturnCICLI::Credential.new(
      user_id: "foo",
      api_token: "bar"
    )
  end

  describe "run" do
    let!(:client) do
      SaturnCICLI::Client.new(credential)
    end

    before do
      AuthenticationHelper.stub_authentication_request

      run_details = {
        "id" => "3efa1a7e",
        "test_suite_run_id" => "7b9c2d3f",
        "created_at" => "2024-02-28 16:00:00",
        "status" => "Passed",
        "test_suite_run_commit_message" => "Fix bug",
        "duration" => "5m 30s"
      }

      APIHelper.stub_body("api/v1/runs/3efa1a7e", run_details)
    end

    it "shows the run" do
      expected_output = <<~OUTPUT
      id: 3efa1a7e
      test_suite_run_id: 7b9c2d3f
      created_at: 2024-02-28 16:00:00
      status: Passed
      test_suite_run_commit_message: Fix bug
      duration: 5m 30s
      OUTPUT

      expect {
        client.execute([:run, "3efa1a7e"])
      }.to output(expected_output).to_stdout
    end
  end

  describe "runs" do
    before do
      AuthenticationHelper.stub_authentication_request

      body = [
        {
          "id" => "cdbe84c7",
          "test_suite_run_id" => "3cbe1b26",
          "created_at" => "2024-02-28 15:38:06",
          "status" => "Passed",
          "test_suite_run_commit_message" => "Did stuff",
        },
        {
          "id" => "6882b373",
          "test_suite_run_id" => "56d2a863",
          "created_at" => "2024-02-28 15:36:18",
          "status" => "Passed",
          "test_suite_run_commit_message" => "Did other stuff",
        },
        {
          "id" => "4c304b55",
          "test_suite_run_id" => "7c8dd048",
          "created_at" => "2024-02-28 01:57:05",
          "status" => "Passed",
          "test_suite_run_commit_message" => "Did yet other stuff",
        },
        {
          "id" => "4cdfb661",
          "test_suite_run_id" => "65a7e250",
          "created_at" => "2024-02-28 01:52:07",
          "status" => "Passed",
          "test_suite_run_commit_message" => "Did similar but different stuff",
        }
      ]

      APIHelper.stub_body("api/v1/runs", body)
    end

    let!(:client) do
      SaturnCICLI::Client.new(credential)
    end

    it "shows runs" do
      expected_output = <<~OUTPUT
      ID        Created              Test suite run status  Test suite run ID  Test suite run commit message
      cdbe84c7  2024-02-28 15:38:06  Passed                 3cbe1b26           Did stuff
      6882b373  2024-02-28 15:36:18  Passed                 56d2a863           Did other stuff
      4c304b55  2024-02-28 01:57:05  Passed                 7c8dd048           Did yet other stuff
      4cdfb661  2024-02-28 01:52:07  Passed                 65a7e250           Did similar but diffe...
      OUTPUT

      expect {
        client.execute([:runs])
      }.to output(expected_output).to_stdout
    end
  end
end
