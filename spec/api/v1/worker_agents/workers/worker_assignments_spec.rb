require "rails_helper"
include APIAuthenticationHelper

describe "Worker assignments", type: :request do
  describe "GET /api/v1/worker_agents/workers/:worker_id/worker_assignments" do
    context "assignment exists" do
      let!(:worker_assignment) { create(:test_runner_assignment) }
      let!(:worker) { worker_assignment.worker }

      it "returns the assignment" do
        get(
          api_v1_worker_agents_worker_worker_assignments_path(worker_id: worker.id, format: :json),
          headers: worker_agents_api_authorization_headers(worker)
        )

        response_body = JSON.parse(response.body)[0]
        expect(response_body["run_id"]).to eq(worker_assignment.run_id)
      end

      context "no project secrets exist" do
        it "assigns env_vars to an empty hash" do
          get(
            api_v1_worker_agents_worker_worker_assignments_path(worker_id: worker.id, format: :json),
            headers: worker_agents_api_authorization_headers(worker)
          )

          response_body = JSON.parse(response.body)[0]
          expect(response_body["env_vars"]).to eq({})
        end
      end
    end
  end

  describe "assignment is created, then test suite run is deleted" do
    it "does not show up in the list of assignments" do
      worker_assignment = create(:test_runner_assignment)
      worker = worker_assignment.worker
      worker_assignment.run.test_suite_run.destroy

      get(
        api_v1_worker_agents_worker_worker_assignments_path(worker_id: worker.id, format: :json),
        headers: worker_agents_api_authorization_headers(worker)
      )

      response_body = JSON.parse(response.body)
      expect(response_body.size).to eq(0)
    end
  end

  describe "when worker does not exist" do
    it "returns bad request with error message" do
      worker = create(:test_runner)

      get(
        api_v1_worker_agents_worker_worker_assignments_path(worker_id: "nonexistent", format: :json),
        headers: worker_agents_api_authorization_headers(worker)
      )

      expect(response).to have_http_status(:bad_request)
      response_body = JSON.parse(response.body)
      expect(response_body["error"]).to be_present
    end
  end
end
