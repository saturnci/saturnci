require "rails_helper"

describe "test suite runs", type: :request do
  let!(:build) { create(:build) }
  before { login_as(build.project.user) }

  describe "GET test_suite_runs" do
    it "include test suite run" do
      get(
        project_builds_path(project_id: build.project_id),
        headers: {
          "Accept" => "text/vnd.turbo-stream.html"
        }
      )

      expect(response.body).to include("turbo-stream")
    end
  end
end
