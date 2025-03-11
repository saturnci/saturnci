require "rails_helper"

describe Cloud::RSAKey do
  it "generates an RSA key" do
    expect {
      Cloud::RSAKey.generate
    }.to change(Cloud::RSAKey, :count).by(1)
  end
end
