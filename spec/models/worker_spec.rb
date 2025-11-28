require "rails_helper"

describe Worker do
  before do
    admin_user = double
    allow(admin_user).to receive(:id).and_return(1)
    allow(admin_user).to receive(:api_token).and_return("token")
    allow(User).to receive(:find_by).and_return(admin_user)
  end

  describe "#assign" do
    it "assigns a run to the test runner" do
      test_runner = create(:test_runner)
      run = create(:run)

      expect { test_runner.assign(run) }
        .to change { test_runner.test_runner_assignment.present? }
        .from(false).to(true)
    end
  end

  describe "scope available" do
    context "when the test runner is available" do
      it "includes the test runner" do
        test_runner = create(:test_runner)
        create(:test_runner_event, worker: test_runner, type: :ready_signal_received)
        expect(Worker.available).to include(test_runner)
      end
    end

    context "when the test runner has an assignment" do
      it "does not include the test runner" do
        test_runner = create(:test_runner)
        create(:test_runner_event, worker: test_runner, type: :ready_signal_received)
        create(:test_runner_assignment, worker: test_runner)
        expect(Worker.available).not_to include(test_runner)
      end
    end

    context "when the test runner is not available" do
      it "does not include the test runner" do
        test_runner = create(:test_runner)
        expect(Worker.available).not_to include(test_runner)
      end
    end
  end

  describe ".provision" do
    before do
      allow(Worker).to receive(:create_vm)
    end

    it "creates a test runner" do
      expect { Worker.provision }
        .to change { Worker.count }
        .from(0).to(1)
    end

    it "sets the test runner's status to Provisioning" do
      test_runner = Worker.provision
      expect(test_runner.status).to eq("Provisioning")
    end

    it "creates an access token" do
      expect { Worker.provision }
        .to change { AccessToken.count }
        .from(0).to(1)
    end

    it "assigns the access token to the test runner" do
      test_runner = Worker.provision
      expect(test_runner.access_token).to be_present
    end
  end

  describe "status" do
    context "ready" do
      it "returns ready" do
        test_runner = create(:test_runner)
        test_runner.test_runner_events.create!(type: :ready_signal_received)
        expect(test_runner.status).to eq("Available")
      end
    end
  end

  describe "#unassigned" do
    context "a test runner is not associated with a run" do
      it "is included" do
        test_runner = create(:test_runner)
        expect(Worker.unassigned).to include(test_runner)
      end
    end

    context "a test runner is associated with a run" do
      it "is not included" do
        test_runner = create(:test_runner)
        run = create(:run)
        test_runner.assign(run)

        expect(Worker.unassigned).not_to include(test_runner)
      end
    end
  end

  describe "#to_json" do
    it "includes the test runner assignment's run's commit message" do
      run = create(:run) do |r|
        r.test_suite_run.update!(commit_message: "Add stuff.")
      end

      create(:test_runner_assignment, run:)

      expect(JSON.parse(run.test_runner.to_json)["commit_message"]).to eq("Add stuff.")
    end
  end
end
