# Fix SSL certificate verification for Ruby's Net::HTTP
# Ruby's OpenSSL tries to verify Certificate Revocation Lists but can't access them
# This explicitly configures the cert store to use the system's default certificate paths

require 'net/http'

module Net
  class HTTP
    alias_method :original_do_start, :do_start

    def do_start
      if use_ssl? && !@cert_store
        @cert_store = OpenSSL::X509::Store.new
        @cert_store.set_default_paths
      end
      original_do_start
    end
  end
end
