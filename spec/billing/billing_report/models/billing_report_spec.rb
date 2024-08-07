require "rails_helper"

RSpec.describe BillingReport, type: :model do
  context "job at the very beginning of a month" do
    let!(:job) { create(:job, created_at: "2020-01-01 00:01:00").finish! }

    it "includes the job" do
      billing_report = BillingReport.new(project: job.build.project, year: 2020, month: 1)

      expect(billing_report.jobs).to include(job)
    end
  end

  context "job at the very end of a month" do
    let!(:job) { create(:job, created_at: "2020-01-31 23:58:00").finish! }

    it "includes the job" do
      billing_report = BillingReport.new(project: job.build.project, year: 2020, month: 1)

      expect(billing_report.jobs).to include(job)
    end
  end
end
