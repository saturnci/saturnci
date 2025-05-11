require "rails_helper"

describe "test suite reruns", type: :request do
  describe "POST test_suite_reruns_path" do
    let!(:test_suite_run) do
      create(:build) do |test_suite_run|
        test_suite_run.project.user.github_accounts.create!(
          github_installation_id: "123456"
        )
      end
    end

    around do |example|
      perform_enqueued_jobs { example.run }
    end

    before do
      allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
      allow(TestRunner).to receive(:create_vm)
      allow(TestRunner).to receive(:available).and_return([create(:test_runner)])
      login_as(test_suite_run.project.user, scope: :user)
    end

    it "increases the count of test suite runs by 1" do
      expect {
        post(test_suite_reruns_path(test_suite_run_id: test_suite_run.id))
      }.to change(TestSuiteRun, :count).by(1)
    end

    it "returns 302 status" do
      post(test_suite_reruns_path(test_suite_run_id: test_suite_run.id))
      expect(response).to have_http_status(302)
    end
  end
end
