require "rails_helper"

describe Cloud::RSAKey do
  let!(:run) { create(:run) }

  it "generates an RSA key" do
    expect {
      Cloud::RSAKey.generate(run)
    }.to change(Cloud::RSAKey, :count).by(1)
  end
end
