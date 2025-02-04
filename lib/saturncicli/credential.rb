module SaturnCICLI
  class Credential
    DEFAULT_HOST = "https://app.saturnci.com"
    attr_reader :host, :user_id, :api_token

    def initialize(host: DEFAULT_HOST, user_id:, api_token:)
      @host = host
      @user_id = user_id
      @api_token = api_token
    end
  end
end
