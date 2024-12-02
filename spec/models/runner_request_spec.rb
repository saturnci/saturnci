require "rails_helper"

RSpec.describe RunnerRequest do
  let!(:run) { create(:run) }

  describe "#execute!" do
    it "works" do
      runner_request = RunnerRequest.new(run: run, github_installation_id: "123456")
      runner_request.execute!
    end
  end
end
