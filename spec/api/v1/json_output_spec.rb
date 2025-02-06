require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "JSON output", type: :request do
  let!(:run) { create(:run) }

  let!(:raw_data) do
    {
      version: "3.13.2",
      seed: 1864,
      examples: [
        {
          id: "./spec/streaming/system_logs/system/visiting_different_tab_spec.rb[1:1:1:1]",
          description: "does not show the system log content",
          full_description: "Visiting different tab visiting a different tab after log update occurs does not show the system log content",
          status: "passed",
          file_path: "./spec/streaming/system_logs/system/visiting_different_tab_spec.rb",
          line_number: 28,
          run_time: 12.255599035,
          pending_message: nil
        },
        {
          id: "./spec/api/v1/runner_spec.rb[1:1:1]",
          description: "deletes the runner",
          full_description: "delete runner terminate_on_completion is true deletes the runner",
          status: "passed",
          file_path: "./spec/api/v1/runner_spec.rb",
          line_number: 16,
          run_time: 0.413684976,
          pending_message: nil
        },
        {
          id: "./spec/api/v1/runner_spec.rb[1:2:1]",
          description: "does not delete the runner",
          full_description: "delete runner terminate_on_completion is false does not delete the runner",
          status: "passed",
          file_path: "./spec/api/v1/runner_spec.rb",
          line_number: 36,
          run_time: 0.136240481,
          pending_message: nil
        }
      ],
      summary: {
        duration: 152.692154288,
        example_count: 3,
        failure_count: 0,
        pending_count: 0,
        errors_outside_of_examples_count: 0
      },
      summary_line: "3 examples, 0 failures"
    }
  end

  describe "POST /api/v1/runs/:id/json_output" do
    it "adds json output to a run" do
      post(
        api_v1_run_json_output_path(run_id: run.id),
        params: raw_data.to_json,
        headers: api_authorization_headers(run.build.project.user).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(run.reload.json_output).to eq(raw_data.to_json)
    end

    it "inserts a test case run for each example" do
      post(
        api_v1_run_json_output_path(run_id: run.id),
        params: raw_data.to_json,
        headers: api_authorization_headers(run.build.project.user).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(JSON.parse(response.body)["test_case_run_count"]).to eq(3)
    end
  end
end
