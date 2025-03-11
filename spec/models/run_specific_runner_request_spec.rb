require "rails_helper"

describe RunSpecificRunnerRequest do
  let!(:run) { create(:run) }

  describe "#execute!" do
    let!(:ssh_key) { double }
    let!(:client) { double }

    let!(:run_specific_runner_request) do
      RunSpecificRunnerRequest.new(
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
      expect { run_specific_runner_request.execute! }
        .to change { run.reload.snapshot_image_id.present? }
        .from(false).to(true)
    end

    it "creates a test runner" do
      expect { run_specific_runner_request.execute! }
        .to change { TestRunner.count }.by(1)
    end

    it "creates an association with a test runner" do
      expect { run_specific_runner_request.execute! }
        .to change { RunTestRunner.count }.by(1)

      expect(run.test_runner).to be_present
    end
  end

  describe "#droplet_name" do
    let!(:run_specific_runner_request) do
      RunSpecificRunnerRequest.new(
        run: nil,
        github_installation_id: nil,
        ssh_key: nil,
        client: nil
      )
    end

    context "project with underscores in name" do
      it "replaces slashes and underscores with dashes" do
        droplet_name = run_specific_runner_request.droplet_name(
          "fabrix-eu/mantel_back",
          "4d2f3088-6b82-4888-8762-0be3eb7500a1"
        )
        expect(droplet_name).to eq("fabrix-eu-mantel-back-run-4d2f3088")
      end
    end
  end
end
