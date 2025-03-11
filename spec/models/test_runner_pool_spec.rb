require "rails_helper"

describe TestRunnerPool do
  describe "#scale" do
    context "scaling to 10" do
      it "creates 10 test runners" do
        expect { TestRunnerPool.scale(10) }
          .to change { TestRunner.count }
          .from(0).to(10)
      end
    end

    context "scaling to 2" do
      it "creates 2 test runners" do
        expect { TestRunnerPool.scale(2) }
          .to change { TestRunner.count }
          .from(0).to(2)
      end
    end

    context "scaling up and then back down" do
      it "works" do
        TestRunnerPool.scale(10)
        expect { TestRunnerPool.scale(2) }
          .to change { TestRunner.count }
          .from(10).to(2)
      end
    end
  end
end
