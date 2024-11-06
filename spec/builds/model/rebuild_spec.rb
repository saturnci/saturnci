require "rails_helper"

RSpec.describe Rebuild, type: :model do
  let!(:original_build) { create(:build) }

  it "does not copy the status" do
    build = Rebuild.create!(original_build)
    expect(build.status).to eq("Not Started")
  end
end
