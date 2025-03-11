require "rails_helper"
include APIAuthenticationHelper

describe "run", type: :request do
  let!(:run) { create(:run) }
  let!(:test_runner) { create(:test_runner) }
  let!(:run_test_runner) { create(:run_test_runner, run:, test_runner:) }

  let!(:user) { run.build.project.user }

  before do
    allow_any_instance_of(RunnerNetwork).to receive(:ip_address).and_return("")
  end

  describe "finding by abbreviated hash" do
    it "finds the run" do
      extend ApplicationHelper

      get(
        api_v1_run_path(abbreviated_hash(run.id)),
        headers: api_authorization_headers(user)
      )
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /api/v1/run/:id" do
    it "returns a 200 response" do
      get(
        api_v1_run_path(run.id),
        headers: api_authorization_headers(user)
      )
      expect(response).to have_http_status(200)
    end

    it "includes the id" do
      get(
        api_v1_run_path(run.id),
        headers: api_authorization_headers(user)
      )
      response_body = JSON.parse(response.body)
      expect(response_body["id"]).to eq(run.id)
    end

    describe "RSA key" do
      before do
        run.test_runner.rsa_key.update!(
          private_key_value: "abc123",
          public_key_value: "def456"
        )
      end

      it "returns the base64 encoded RSA key" do
        get(
          api_v1_run_path(run.id),
          headers: api_authorization_headers(user)
        )
        response_body = JSON.parse(response.body)
        expect(response_body["rsa_key"]).to eq("YWJjMTIz")
      end
    end
  end
end
