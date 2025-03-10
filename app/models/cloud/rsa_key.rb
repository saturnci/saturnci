require "fileutils"

module Cloud
  class RSAKey < ApplicationRecord
    TMP_DIR_NAME = "/tmp/saturnci"

    def self.generate
      FileUtils.mkdir_p(TMP_DIR_NAME)
      file_path = File.join(TMP_DIR_NAME, "rsa-key-#{SecureRandom.hex}")
      system("ssh-keygen -t rsa -b 4096 -N '' -f #{file_path} > /dev/null")

      create!(
        private_key_value: File.read(file_path),
        public_key_value: File.read("#{file_path}.pub")
      )
    end
  end
end
