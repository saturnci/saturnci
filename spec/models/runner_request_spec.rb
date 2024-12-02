require "rails_helper"

RSpec.describe RunnerRequest do
  let!(:run) { create(:run) }

  describe "#execute!" do
    let!(:ssh_key) { double }
    let!(:client) { double }

    let!(:runner_request) do
      RunnerRequest.new(
        run: run,
        github_installation_id: "123456",
        ssh_key: ssh_key,
        client: client
      )
    end

    before do
      allow(ssh_key).to receive(:id).and_return("111")
      allow(ssh_key).to receive(:rsa_key).and_return(double(file_path: "path/to/rsa/key"))

      droplet_request = double
      allow(droplet_request).to receive(:id).and_return("222")
      allow(client).to receive_message_chain(:droplets, :create).and_return(droplet_request)
    end

    it "populates snapshot image id" do
      expect { runner_request.execute! }
        .to change { run.reload.snapshot_image_id.present? }
        .from(false).to(true)
    end
  end
end
