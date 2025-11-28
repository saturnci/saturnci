require "rails_helper"

describe WorkerPool do
  describe "#scale" do
    before do
      allow(Worker).to receive(:create_vm)
    end

    let!(:worker_pool) { WorkerPool.instance }

    context "scaling to 10" do
      it "creates 10 test runners" do
        expect {
          worker_pool.scale(10)
        }.to change { Worker.count }.from(0).to(10)
      end
    end

    context "scaling to 2" do
      it "creates 2 test runners" do
        expect {
          worker_pool.scale(2)
        }.to change { Worker.count }.from(0).to(2)
      end
    end

    context "scaling up and then back down" do
      before do
        client = double
        allow(client).to receive_message_chain(:droplets, :delete)
        allow(DropletKitClientFactory).to receive(:client).and_return(client)
      end

      it "works" do
        worker_pool.scale(10)

        expect {
          worker_pool.scale(2)
        }.to change { Worker.count }.from(10).to(2)
      end
    end

    context "scaling and then scaling again to the same number" do
      it "does not delete test runners" do
        worker_pool.scale(2)

        expect {
          worker_pool.scale(2)
        }.not_to change { Worker.all.map(&:id) }
      end
    end
  end

  describe ".target_size" do
    before do
      stub_const("ENV", ENV.to_hash.merge("TEST_RUNNER_FLEET_SIZE" => "10"))
      create(:run)
    end

    context "a run has been created within the last hour" do
      it "returns TEST_RUNNER_FLEET_SIZE" do
        expect(WorkerPool.target_size).to eq(10)
      end
    end

    context "a run has not been created within the last hour" do
      it "returns 0" do
        travel_to(2.hours.from_now) do
          expect(WorkerPool.target_size).to eq(0)
        end
      end
    end
  end
end
