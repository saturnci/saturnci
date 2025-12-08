require "rails_helper"

describe "failure reruns", type: :request do
  describe "POST failure_reruns_path" do
    let!(:test_suite_run) { create(:test_suite_run) }

    before do
      allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
      login_as(test_suite_run.repository.user, scope: :user)
    end

    it "creates a new test suite run" do
      expect {
        post(failure_reruns_path(test_suite_run_id: test_suite_run.id))
      }.to change(TestSuiteRun, :count).by(1)
    end
  end
end
