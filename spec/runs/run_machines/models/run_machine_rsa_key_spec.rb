require "rails_helper"

describe Cloud::RSAKey do
  let!(:tmp_dir_name) { Rails.root.join("tmp", "saturnci") }

  before do
    stub_const("Cloud::RSAKey::TMP_DIR_NAME", tmp_dir_name)
  end

  after(:each) do
    FileUtils.rm_rf(Dir.glob("#{tmp_dir_name}/*"))
  end

  it "creates a file" do
    rsa_key = Cloud::RSAKey.new("run-123")
    expect(File.exist?(rsa_key.file_path)).to be true
  end
end
