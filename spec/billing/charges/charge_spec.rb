require "rails_helper"

RSpec.describe "Charges", type: :system do
  context "before a run has finished" do
    let!(:run) { create(:run) }

    it "does not have a charge" do
      expect(run.charge).to be nil
    end
  end

  context "when a run finishes" do
    let!(:run) { create(:run) }

    before do
      allow(Rails.configuration).to receive(:charge_rate).and_return(0.2)
      run.finish!
    end

    it "captures the charge rate at that point in time" do
      expect(run.charge.rate).to eq(0.2)
    end
  end
end
