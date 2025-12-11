require "rails_helper"

describe "test suite runs", type: :request do
  let!(:test_suite_run) { create(:test_suite_run) }
  before { login_as(test_suite_run.repository.user) }

  describe "GET test_suite_runs" do
    it "include test suite run" do
      get(
        repository_test_suite_runs_path(repository_id: test_suite_run.repository_id),
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
      )

      expect(response.body).to include("turbo-stream")
    end
  end
end
