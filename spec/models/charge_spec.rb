require "rails_helper"

RSpec.describe Charge, type: :model do
  let!(:charge) do
    create(:charge, job_duration: 300, rate: 0.1)
  end

  describe "#amount_cents" do
    it "is the duration times the rate" do
      expect(charge.amount_cents).to eq(30)
    end
  end

  describe "#amount" do
    it "is amount_cents in dollars" do
      expect(charge.amount).to eq(0.3)
    end
  end
end
