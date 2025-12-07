RSpec.describe "Flaky test" do
  it "sometimes fails" do
    expect(rand(1..2)).to eq(1)
  end
end
