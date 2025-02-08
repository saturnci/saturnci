require "rails_helper"

describe "test case run", type: :request do
  let!(:test_case_run) do
    create(
      :test_case_run,
      description: "My test",
      run: create(:run, :passed)
    )
  end

  before do
    login_as(test_case_run.project.user)
  end

  context "going straight to the test case run page" do
    it "includes the test case run description" do
      get project_test_case_run_path(test_case_run.project, test_case_run)
      expect(response.body).to include(test_case_run.description)
    end
  end

  context "visiting build" do
    it "redirects to the test case run page" do
      get project_build_path(test_case_run.project, test_case_run.run.build)
      expect(response).to redirect_to(project_test_case_run_path(test_case_run.project, test_case_run))
    end

    context "turbo request" do
      it "redirects to the test case run page" do
        get project_build_path(test_case_run.project, test_case_run.run.build), headers: { "Turbo-Frame" => "true" }
        expect(response.body).to include(test_case_run.description)
      end
    end
  end
end
