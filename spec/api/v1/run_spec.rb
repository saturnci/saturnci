require "rails_helper"
include APIAuthenticationHelper

describe "run", type: :request do
  let!(:run) { create(:run) }
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

    context "RSA key file does not exist" do
      it "returns an empty RSA key" do
        get(
          api_v1_run_path(run.id),
          headers: api_authorization_headers(user)
        )
        response_body = JSON.parse(response.body)
        expect(response_body["rsa_key"]).to be_blank
      end
    end

    context "RSA key file exists" do
      before do
        Cloud::RSAKey.create!(
          run:,
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
