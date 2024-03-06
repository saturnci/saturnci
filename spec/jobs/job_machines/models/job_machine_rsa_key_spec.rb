require "rails_helper"

describe JobMachineRSAKey do
  let!(:job) { create(:job) }
  let!(:tmp_dir_name) { Rails.root.join("tmp", "saturnci") }

  after(:each) do
    FileUtils.rm_rf(Dir.glob("#{tmp_dir_name}/*"))
  end

  it "creates a file" do
    job_machine_rsa_key = JobMachineRSAKey.new(job, tmp_dir_name)
    expect(File.exist?(job_machine_rsa_key.file_path)).to be true
  end
end
