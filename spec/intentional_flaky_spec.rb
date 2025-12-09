require "rails_helper"

describe "intentional flaky test" do
  it "fails approximately 50% of the time" do
    expect(rand < 0.5).to eq(true)
  end
end
