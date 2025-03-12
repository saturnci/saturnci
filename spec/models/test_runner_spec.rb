require "rails_helper"

describe TestRunner do
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
