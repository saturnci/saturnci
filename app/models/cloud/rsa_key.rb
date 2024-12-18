require "fileutils"
require "securerandom"

module Cloud
  class RSAKey
    TMP_DIR_NAME = "/tmp/saturnci"
    attr_reader :filename

    # tmp_dir_name is configurable so that a different directory
    # can be used in the test environment as to not conflict with
    # the development environment
    def initialize(filename)
      @filename = filename

      FileUtils.mkdir_p(TMP_DIR_NAME)
      system("ssh-keygen -t rsa -b 4096 -N '' -f #{file_path} > /dev/null")
    end

    def file_path
      "#{TMP_DIR_NAME}/#{@filename}"
    end
  end
end
