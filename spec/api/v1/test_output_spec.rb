require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "test output", type: :request do
  let!(:run) { create(:run) }

  describe "POST /api/v1/runs/:id/test_output" do
    it "adds test output to a run" do
      post(
        api_v1_run_test_output_path(run_id: run.id),
        params: Base64.encode64("test output content"),
        headers: api_authorization_headers(run.build).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(run.reload.test_output).to eq("test output content")
    end
  end

  describe "appending" do
    it "appends anything new to the end of the test output rather than replacing the log content entirely" do
      post(
        api_v1_run_test_output_path(run_id: run.id),
        params: Base64.encode64("first chunk "),
        headers: api_authorization_headers(run.build).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      post(
        api_v1_run_test_output_path(run_id: run.id),
        params: Base64.encode64("second chunk"),
        headers: api_authorization_headers(run.build).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(run.reload.test_output).to eq("first chunk second chunk")
    end
  end
end
