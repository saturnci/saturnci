require "rails_helper"

describe Cloud::SSHKey do
  it "generates an SSH key" do
    ssh_key = Cloud::SSHKey.new(Cloud::RSAKey.generate)
  end
end
