require "rails_helper"

describe "test case run", type: :request do
  let!(:test_case_run) do
    create(
      :test_case_run,
      description: "My test",
      run: create(:run, :passed)
    )
  end

  describe "GET project_test_case_run_path" do
    before do
      login_as(test_case_run.project.user)
    end

    it "returns a success response" do
      get project_test_case_run_path(test_case_run.project, test_case_run)
      expect(response.body).to include(test_case_run.description)
    end
  end
end
