require "rails_helper"

RSpec.describe Billing::JobDecorator do
  let!(:job) { create(:job) }

  describe "#charge" do
    before do
      allow(job).to receive(:duration).and_return(60)
    end

    it "returns the charge" do
      decorated_job = Billing::JobDecorator.new(job)
      expect(decorated_job.charge).to eq(0.06)
    end
  end
end
