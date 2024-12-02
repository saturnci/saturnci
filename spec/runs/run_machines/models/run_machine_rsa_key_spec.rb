require "rails_helper"

describe RunnerRSAKey do
  let!(:tmp_dir_name) { Rails.root.join("tmp", "saturnci") }

  before do
    stub_const('RunnerRSAKey::TMP_DIR_NAME', tmp_dir_name)
  end

  after(:each) do
    FileUtils.rm_rf(Dir.glob("#{tmp_dir_name}/*"))
  end

  it "creates a file" do
    runner_rsa_key = RunnerRSAKey.new("run-123")
    expect(File.exist?(runner_rsa_key.file_path)).to be true
  end
end
