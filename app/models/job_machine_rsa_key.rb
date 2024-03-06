require "fileutils"
require "securerandom"

class JobMachineRSAKey
  TMP_DIR_NAME = "/tmp/saturnci"
  attr_reader :filename

  def initialize(job, tmp_dir_name = TMP_DIR_NAME)
    @job = job
    @tmp_dir_name = tmp_dir_name
    @filename = "job-#{@job.id}-#{SecureRandom.hex}"

    FileUtils.mkdir_p(@tmp_dir_name)
    system("ssh-keygen -t rsa -b 4096 -N '' -f #{file_path} > /dev/null")
  end

  def file_path
    "#{@tmp_dir_name}/#{filename}"
  end
end
