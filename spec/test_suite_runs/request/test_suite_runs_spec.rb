require "rails_helper"

describe "test suite runs", type: :request do
  let!(:test_suite_run) { create(:build) }
  before { login_as(test_suite_run.project.user) }

  describe "GET test_suite_runs" do
    it "include test suite run" do
      get(
        project_test_suite_runs_path(project_id: test_suite_run.project_id),
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
      )

      expect(response.body).to include("turbo-stream")
    end
  end
end
