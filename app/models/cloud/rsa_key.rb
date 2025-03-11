require "net/ssh"
require "openssl"

module Cloud
  class RSAKey < ApplicationRecord
    def self.generate
      rsa_key = OpenSSL::PKey::RSA.new(4096)
      private_key = rsa_key.to_pem
      public_key = Net::SSH::Buffer.from(:key, rsa_key).to_s

      create!(
        private_key_value: private_key,
        public_key_value: "ssh-rsa #{[public_key].pack('m0')}"
      )
    end
  end
end
