require "rails_helper"

describe TestRunnerPool do
  describe "#scale" do
    it "works" do
      expect { TestRunnerPool.scale(10) }
        .to change { TestRunner.count }
        .from(0).to(10)
    end
  end
end
