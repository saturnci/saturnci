require "rails_helper"

describe Worker do
  before do
    admin_user = double
    allow(admin_user).to receive(:id).and_return(1)
    allow(admin_user).to receive(:api_token).and_return("token")
    allow(User).to receive(:find_by).and_return(admin_user)
  end

  describe "#assign" do
    it "assigns a run to the worker" do
      worker = create(:worker)
      run = create(:run)

      expect { worker.assign(run) }
        .to change { worker.worker_assignment.present? }
        .from(false).to(true)
    end
  end

  describe "scope available" do
    context "when the worker is available" do
      it "includes the worker" do
        worker = create(:worker)
        create(:worker_event, worker: worker, type: :ready_signal_received)
        expect(Worker.available).to include(worker)
      end
    end

    context "when the worker has an assignment" do
      it "does not include the worker" do
        worker = create(:worker)
        create(:worker_event, worker: worker, type: :ready_signal_received)
        create(:worker_assignment, worker: worker)
        expect(Worker.available).not_to include(worker)
      end
    end

    context "when the worker is not available" do
      it "does not include the worker" do
        worker = create(:worker)
        expect(Worker.available).not_to include(worker)
      end
    end
  end

  describe ".provision" do
    before do
      allow(Worker).to receive(:create_vm)
    end

    it "creates a worker" do
      expect { Worker.provision }
        .to change { Worker.count }
        .from(0).to(1)
    end

    it "sets the worker's status to Provisioning" do
      worker = Worker.provision
      expect(worker.status).to eq("Provisioning")
    end

    it "creates an access token" do
      expect { Worker.provision }
        .to change { AccessToken.count }
        .from(0).to(1)
    end

    it "assigns the access token to the worker" do
      worker = Worker.provision
      expect(worker.access_token).to be_present
    end
  end

  describe "status" do
    context "ready" do
      it "returns ready" do
        worker = create(:worker)
        worker.worker_events.create!(type: :ready_signal_received)
        expect(worker.status).to eq("Available")
      end
    end
  end

  describe "#unassigned" do
    context "a worker is not associated with a run" do
      it "is included" do
        worker = create(:worker)
        expect(Worker.unassigned).to include(worker)
      end
    end

    context "a worker is associated with a run" do
      it "is not included" do
        worker = create(:worker)
        run = create(:run)
        worker.assign(run)

        expect(Worker.unassigned).not_to include(worker)
      end
    end
  end

  describe "#to_json" do
    it "includes the worker assignment's run's commit message" do
      run = create(:run) do |r|
        r.test_suite_run.update!(commit_message: "Add stuff.")
      end

      create(:worker_assignment, run:)

      expect(JSON.parse(run.worker.to_json)["commit_message"]).to eq("Add stuff.")
    end
  end
end
