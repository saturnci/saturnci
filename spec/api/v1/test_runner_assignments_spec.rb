require "rails_helper"
include APIAuthenticationHelper

describe "Test runner assignments", type: :request do
  describe "GET /api/v1/test_runners/:test_runner_id/test_runner_assignments" do
    context "assignment exists" do
      it "returns the assignment" do
        test_runner_assignment = create(:test_runner_assignment)
        user = create(:user, super_admin: true)

        get(
          api_v1_test_runner_test_runner_assignments_path(test_runner_id: test_runner_assignment.test_runner_id, format: :json),
          headers: api_authorization_headers(user)
        )

        response_body = JSON.parse(response.body)[0]
        expect(response_body["run_id"]).to eq(test_runner_assignment.run_id)
      end
    end
  end

  describe "assignment is created, then test suite run is deleted" do
    it "does not show up in the list of assignments" do
      test_runner_assignment = create(:test_runner_assignment)
      test_runner_assignment.run.test_suite_run.destroy

      user = create(:user, super_admin: true)

      get(
        api_v1_test_runner_test_runner_assignments_path(test_runner_id: test_runner_assignment.test_runner_id, format: :json),
        headers: api_authorization_headers(user)
      )

      response_body = JSON.parse(response.body)
      expect(response_body.size).to eq(0)
    end
  end
end
