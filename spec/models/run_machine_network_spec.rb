require "rails_helper"

describe RunnerNetwork do
  context "public network is missing" do
    it "returns nil for IP address" do
      runner_network = RunnerNetwork.new("12345")
      allow(runner_network).to receive(:droplet).and_return(nil)
      allow(runner_network).to receive(:public_network).and_return(nil)

      expect(runner_network.ip_address).to be nil
    end
  end
end
