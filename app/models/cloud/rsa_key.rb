require "openssl"
require "net/ssh"

module Cloud
  class RSAKey < ApplicationRecord
    belongs_to :run

    def self.generate(run)
      rsa_key = OpenSSL::PKey::RSA.new(4096)
      private_key = rsa_key.to_pem
      public_key = Net::SSH::Buffer.from(:key, rsa_key).to_s

      create!(
        run: run,
        private_key_value: private_key,
        public_key_value: "ssh-rsa #{[public_key].pack('m0')}"
      )
    end
  end
end
