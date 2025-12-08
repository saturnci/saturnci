require "rails_helper"

describe "Intentionally failing test" do
  it "fails on purpose" do
    expect(true).to eq(false)
  end
end
