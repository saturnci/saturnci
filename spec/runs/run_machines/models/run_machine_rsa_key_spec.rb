require "rails_helper"

describe Cloud::RSAKey do
  let!(:tmp_dir_name) { Rails.root.join("tmp", "saturnci") }
  let!(:run) { create(:run) }

  before do
    stub_const("Cloud::RSAKey::TMP_DIR_NAME", tmp_dir_name)
  end

  after do
    FileUtils.rm_rf(Dir.glob("#{tmp_dir_name}/*"))
  end

  it "creates a key" do
    rsa_key = Cloud::RSAKey.generate(run)
    expect(rsa_key.private_key_value).to be_present
    expect(rsa_key.public_key_value).to be_present
  end
end
