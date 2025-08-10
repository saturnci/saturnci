require "rails_helper"

describe TestRunnerFleet do
  describe "#scale" do
    before do
      allow(TestRunner).to receive(:create_vm)
    end

    context "scaling to 10" do
      it "creates 10 test runners" do
        expect {
          TestRunnerFleet.scale(10)
        }.to change { TestRunner.count }.from(0).to(10)
      end
    end

    context "scaling to 2" do
      it "creates 2 test runners" do
        expect {
          TestRunnerFleet.scale(2)
        }.to change { TestRunner.count }.from(0).to(2)
      end
    end

    context "scaling up and then back down" do
      before do
        client = double
        allow(client).to receive_message_chain(:droplets, :delete)
        allow(DropletKitClientFactory).to receive(:client).and_return(client)
      end

      it "works" do
        TestRunnerFleet.scale(10)

        expect {
          TestRunnerFleet.scale(2)
        }.to change { TestRunner.count }.from(10).to(2)
      end
    end

    context "scaling and then scaling again to the same number" do
      it "does not delete test runners" do
        TestRunnerFleet.scale(2)

        expect {
          TestRunnerFleet.scale(2)
        }.not_to change { TestRunner.all.map(&:id) }
      end
    end
  end
end
