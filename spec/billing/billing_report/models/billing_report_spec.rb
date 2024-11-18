require "rails_helper"

RSpec.describe BillingReport, type: :model do
  context "run at the very beginning of a month" do
    let!(:run) { create(:run, created_at: "2020-01-01 00:01:00").finish! }

    it "includes the run" do
      billing_report = BillingReport.new(project: run.build.project, year: 2020, month: 1)

      expect(billing_report.runs).to include(run)
    end
  end

  context "run at the very end of a month" do
    let!(:run) { create(:run, created_at: "2020-01-31 23:58:00").finish! }

    it "includes the run" do
      billing_report = BillingReport.new(project: run.build.project, year: 2020, month: 1)

      expect(billing_report.runs).to include(run)
    end
  end
end
