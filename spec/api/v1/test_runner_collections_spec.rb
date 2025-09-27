require "rails_helper"
include APIAuthenticationHelper

describe "Test runner collections", type: :request do
  let!(:user) { create(:user, super_admin: true) }

  context "test runner status is finished" do
    let!(:finished_test_runner) { create(:test_runner) }

    before do
      finished_test_runner.test_runner_events.create!(type: :test_run_finished)
    end

    it "does not delete the test runner" do
      expect {
        delete(
          api_v1_test_runner_collection_path,
          headers: api_authorization_headers(user)
        )
      }.not_to change { TestRunner.count }
    end
  end

  context "test runner status is something other than finished" do
    let!(:available_test_runner) { create(:test_runner) }

    before do
      available_test_runner.test_runner_events.create!(type: :ready_signal_received)
      allow_any_instance_of(TestRunner).to receive(:deprovision)
    end

    it "deletes the test runner" do
      expect {
        delete(
          api_v1_test_runner_collection_path,
          headers: api_authorization_headers(user)
        )
      }.to change { TestRunner.count }.by(-1)
    end
  end
end
