require "rails_helper"

describe TestRunnerPool do
  describe "#scale" do
    let!(:client) { double }

    before do
      allow(TestRunner).to receive(:create_vm)
    end

    context "scaling to 10" do
      it "creates 10 test runners" do
        expect {
          TestRunnerPool.scale(10, client:)
        }.to change { TestRunner.count }.from(0).to(10)
      end
    end

    context "scaling to 2" do
      it "creates 2 test runners" do
        expect {
          TestRunnerPool.scale(2, client:)
        }.to change { TestRunner.count }.from(0).to(2)
      end
    end

    context "scaling up and then back down" do
      before do
        allow(client).to receive_message_chain(:droplets, :delete)
      end

      it "works" do
        TestRunnerPool.scale(10, client:)

        expect {
          TestRunnerPool.scale(2, client:)
        }.to change { TestRunner.count }.from(10).to(2)
      end
    end

    context "scaling and then scaling again to the same number" do
      it "does not delete test runners" do
        TestRunnerPool.scale(2, client:)

        expect {
          TestRunnerPool.scale(2, client:)
        }.not_to change { TestRunner.all.map(&:id) }
      end
    end
  end
end
