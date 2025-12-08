require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "test output", type: :request do
  let!(:task) { create(:run, :with_worker) }
  let!(:worker) { task.worker }

  describe "POST /api/v1/worker_agents/tasks/:task_id/test_output" do
    it "adds test output to a task" do
      post(
        api_v1_worker_agents_task_test_output_path(task_id: task.id),
        params: Base64.encode64("test output content"),
        headers: worker_agents_api_authorization_headers(worker).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(task.reload.test_output).to eq("test output content")
    end
  end

  describe "appending" do
    it "appends anything new to the end of the test output rather than replacing the log content entirely" do
      post(
        api_v1_worker_agents_task_test_output_path(task_id: task.id),
        params: Base64.encode64("first chunk "),
        headers: worker_agents_api_authorization_headers(worker).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      post(
        api_v1_worker_agents_task_test_output_path(task_id: task.id),
        params: Base64.encode64("second chunk"),
        headers: worker_agents_api_authorization_headers(worker).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(task.reload.test_output).to eq("first chunk second chunk")
    end
  end
end
