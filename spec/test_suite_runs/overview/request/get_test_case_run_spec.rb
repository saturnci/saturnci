require "rails_helper"

describe "test case run", type: :request do
  let!(:run) { create(:run, :failed) }

  let!(:passed_test_case_run) do
    create(
      :test_case_run,
      run:,
      status: "passed",
      description: "My passed test",
    )
  end

  let!(:failed_test_case_run) do
    create(
      :test_case_run,
      run:,
      status: "failed",
      description: "My failed test",
    )
  end

  before do
    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
    login_as(passed_test_case_run.repository.user)
  end

  context "going straight to the test case run page" do
    it "includes the test case run description" do
      get repository_test_case_run_path(run.build.repository, passed_test_case_run)
      expect(response.body).to include("My passed test")
    end
  end

  context "visiting build" do
    it "redirects to the test case run page for the first failed test case" do
      get repository_build_path(run.build.repository, run.build)

      expect(response).to redirect_to(
        repository_test_case_run_path(run.build.repository, failed_test_case_run)
      )
    end

    context "turbo request" do
      it "redirects to the test case run page" do
        get repository_build_path(run.build.repository, run.build), headers: { "Turbo-Frame" => "true" }
        expect(response.body).to include("My failed test")
      end
    end
  end
end
