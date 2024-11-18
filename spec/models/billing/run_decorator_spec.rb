require "rails_helper"

RSpec.describe Billing::RunDecorator do
  let!(:run) { create(:run) }

  describe "#charge" do
    before do
      allow(run).to receive(:duration).and_return(60)
    end

    it "returns the charge" do
      decorated_run = Billing::RunDecorator.new(run)
      expect(decorated_run.charge).to eq(0.06)
    end
  end
end
