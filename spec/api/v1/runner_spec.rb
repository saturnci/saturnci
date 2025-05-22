require "rails_helper"
include APIAuthenticationHelper

describe "Delete runner", type: :request do
  let!(:run) { create(:run, :with_test_runner) }

  context "terminate_on_completion is true" do
    let!(:endpoint) do
      %r{https://api.digitalocean.com/v2/droplets/\w+}
    end

    before do
      stub_request(:delete, endpoint).to_return(status: 200, body: "", headers: {})
    end

    it "deletes the runner" do
      delete(
        api_v1_run_runner_path(run.id),
        headers: api_authorization_headers(run.test_suite_run.project.user)
      )

      expect(response).to have_http_status(200)
      expect(a_request(:delete, endpoint)).to have_been_made.once
    end
  end

  context "terminate_on_completion is false" do
    let!(:run) do
      create(:run, :with_test_runner)
    end

    let!(:endpoint) do
      %r{https://api.digitalocean.com/v2/droplets/\w+}
    end

    it "does not delete the runner" do
      run.test_runner.update!(terminate_on_completion: false)

      delete(
        api_v1_run_runner_path(run.id),
        headers: api_authorization_headers(run.test_suite_run.project.user)
      )

      expect(response).to have_http_status(200)
      expect(a_request(:delete, endpoint)).not_to have_been_made
    end
  end
end
