require "fileutils"

module Cloud
  class RSAKey < ApplicationRecord
    belongs_to :run
    TMP_DIR_NAME = "/tmp/saturnci"

    def self.generate(run)
      FileUtils.mkdir_p(TMP_DIR_NAME)
      file_path = File.join(TMP_DIR_NAME, "rsa-key-run-#{run.id}")
      system("ssh-keygen -t rsa -b 4096 -N '' -f #{file_path} > /dev/null")

      create!(
        run:,
        private_key_value: File.read(file_path),
        public_key_value: File.read("#{file_path}.pub")
      )
    end
  end
end
