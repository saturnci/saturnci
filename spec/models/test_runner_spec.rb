require "rails_helper"

describe TestRunner do
  before do
    admin_user = double
    allow(admin_user).to receive(:id).and_return(1)
    allow(admin_user).to receive(:api_token).and_return("token")
    allow(User).to receive(:find_by).and_return(admin_user)
  end

  describe ".provision" do
    let!(:client) { double }

    before do
      droplet_request = double
      allow(droplet_request).to receive(:id) { rand(10000000) }
      allow(client).to receive_message_chain(:droplets, :create).and_return(droplet_request)

      ssh_key = double
      allow(ssh_key).to receive(:id).and_return("333")
      allow(client).to receive_message_chain(:ssh_keys, :create).and_return(ssh_key)
    end

    it "creates a test runner" do
      expect { TestRunner.provision(client:) }
        .to change { TestRunner.count }
        .from(0).to(1)
    end

    it "sets the test runner's status to Provisioning" do
      test_runner = TestRunner.provision(client:)
      expect(test_runner.status).to eq("Provisioning")
    end
  end

  describe "status" do
    context "ready" do
      it "returns ready" do
        test_runner = create(:test_runner)
        test_runner.test_runner_events.create!(type: :ready_signal_received)
        expect(test_runner.status).to eq("Ready")
      end
    end
  end

  describe "#unassigned" do
    context "a test runner is not associated with a run" do
      it "is included" do
        test_runner = create(:test_runner)
        expect(TestRunner.unassigned).to include(test_runner)
      end
    end

    context "a test runner is associated with a run" do
      it "is not included" do
        test_runner = create(:test_runner)
        run = create(:run)
        RunTestRunner.create!(run:, test_runner:)

        expect(TestRunner.unassigned).not_to include(test_runner)
      end
    end
  end
end
