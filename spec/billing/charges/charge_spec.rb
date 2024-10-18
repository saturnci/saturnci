require "rails_helper"

RSpec.describe "Charges", type: :system do
  context "before a job has finished" do
    let!(:job) { create(:job) }

    it "does not have a charge" do
      expect(job.charge).to be nil
    end
  end

  context "when a job finishes" do
    let!(:job) { create(:job) }

    before do
      allow(Rails.configuration).to receive(:charge_rate).and_return(0.2)
      job.finish!
    end

    it "captures the charge rate at that point in time" do
      expect(job.charge.rate).to eq(0.2)
    end
  end
end
