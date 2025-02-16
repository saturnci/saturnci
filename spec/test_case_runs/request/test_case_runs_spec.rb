require "rails_helper"

describe "test case runs", type: :request do
  let!(:run) { create(:run) }

  let!(:test_case_runs) do
    create_list(:test_case_run, 3, run:)
  end

  before do
    login_as(run.project.user)
  end

  describe "GET test_case_runs" do
    it "returns 3 test case runs" do
      get build_test_case_runs_path(build_id: run.build_id)
      expect(JSON.parse(response.body).count).to eq(3)
    end
  end
end
