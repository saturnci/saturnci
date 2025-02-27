require "rails_helper"

describe "rebuilds", type: :request do
  describe "POST rebuilds" do
    let!(:build) do
      create(:build) do |build|
        build.project.user.github_accounts.create!(
          github_installation_id: "123456"
        )
      end
    end

    before do
      login_as(build.project.user, scope: :user)

      runner_request_double = instance_double(RunnerRequest)
      allow(RunnerRequest).to receive(:new).and_return(runner_request_double)
      allow(runner_request_double).to receive(:execute!)
    end

    it "increases the count of builds by 1" do
      expect {
        post(rebuilds_path(build_id: build.id))
      }.to change(Build, :count).by(1)
    end

    it "returns 302 status" do
      post(rebuilds_path(build_id: build.id))
      expect(response).to have_http_status(302)
    end
  end
end
