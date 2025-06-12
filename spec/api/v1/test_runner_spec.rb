require "rails_helper"
include APIAuthenticationHelper

describe "Test runners", type: :request do
  let!(:user) { create(:user, super_admin: true) }
  let!(:test_runner) { create(:test_runner) }

  describe "GET /api/v1/test_runners" do
    it "returns a list of test runners" do
      get(api_v1_test_runners_path, headers: api_authorization_headers(user))
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /api/v1/test_runners/:id" do
    before do
      allow_any_instance_of(RunnerNetwork).to receive(:ip_address).and_return("")
    end

    context "a test runner exists" do
      it "returns a 200 response" do
        get(
          api_v1_test_runner_path(test_runner.id),
          headers: api_authorization_headers(user)
        )
        expect(response).to have_http_status(200)
      end

      context "a run assignment exists" do
        let!(:run) { create(:run) }

        before do
          test_runner.assign(run)
        end

        it "includes the run id" do
          get(
            api_v1_test_runner_path(test_runner.id),
            headers: api_authorization_headers(user)
          )

          expect(response).to have_http_status(200)
          expect(JSON.parse(response.body)["run_id"]).to eq(run.id)
        end
      end
    end

    context "a test runner does not exist" do
      it "returns a 404 response" do
        get(
          api_v1_test_runner_path("123"),
          headers: api_authorization_headers(user)
        )

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)["error"]).to eq("Test runner 123 not found")
      end
    end
  end

  describe "PATCH /api/v1/test_runners/:id" do
    it "changes terminate_on_completion from true to false" do
      extend ApplicationHelper

      patch(
        api_v1_test_runner_path(test_runner.id),
        params: { "terminate_on_completion" => "false" },
        headers: api_authorization_headers(user)
      )

      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["terminate_on_completion"]).to eq(false)
    end
  end

  describe "DELETE /api/v1/test_runners/:id" do
    before do
      client = double
      allow(client).to receive_message_chain(:droplets, :delete)
      allow(DropletKitClientFactory).to receive(:client).and_return(client)
    end

    it "deletes the test runner" do
      delete(
        api_v1_test_runner_path(test_runner.id),
        headers: api_authorization_headers(user)
      )

      expect(response).to have_http_status(204)
      expect(TestRunner.exists?(test_runner.id)).to eq(false)
    end
  end
end
