require "rails_helper"

describe TestRunOrchestrationCheck do
  let!(:c) { TestRunOrchestrationCheck.new }

  describe "#test_runner_fleet_size" do
    before do
      stub_const("ENV", ENV.to_hash.merge("TEST_RUNNER_FLEET_SIZE" => "10"))
      create(:run)
    end

    context "a run has been created within the last hour" do
      it "returns TEST_RUNNER_FLEET_SIZE" do
        expect(c.test_runner_fleet_size).to eq(10)
      end
    end

    context "a run has not been created within the last hour" do
      it "returns 0" do
        travel_to(2.hours.from_now) do
          expect(c.test_runner_fleet_size).to eq(0)
        end
      end
    end
  end
end
