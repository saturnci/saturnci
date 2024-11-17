require "rails_helper"

describe JobMachineNetwork do
  context "public network is missing" do
    it "returns nil for IP address" do
      job_machine_network = JobMachineNetwork.new("12345")
      allow(job_machine_network).to receive(:droplet).and_return(nil)
      allow(job_machine_network).to receive(:public_network).and_return(nil)

      expect(job_machine_network.ip_address).to be nil
    end
  end
end
