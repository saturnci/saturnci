require "rails_helper"

describe "test case runs", type: :request do
  let!(:run) { create(:run) }

  let!(:test_case_run) { create(:test_case_run, run:) }

  before { login_as(run.project.user) }

  describe "GET test_case_runs" do
    it "include test case run" do
      get(
        build_test_case_runs_path(build_id: run.build_id),
        headers: {
          "Accept" => "text/vnd.turbo-stream.html"
        }
      )

      expect(response.body).to include("turbo-stream")
    end
  end
end
