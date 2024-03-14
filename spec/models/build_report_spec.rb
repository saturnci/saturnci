require "rails_helper"

RSpec.describe BuildReport, type: :model do
  context "content is nil" do
    it "does not raise an error" do
      build_report = BuildReport.new(nil)

      expect { build_report.to_s }.not_to raise_error
    end
  end
end
