module SaturnCICLI
  class Credential
    DEFAULT_HOST = "https://app.saturnci.com"
    attr_reader :host, :user_id, :api_token

    def initialize(host: DEFAULT_HOST, user_id:, api_token:)
      @host = host
      @user_id = user_id
      @api_token = api_token
    end

    def valid?
      return true if api_request.response.code == "200"

      api_request(debug: true).response
      false
    end

    private

    def api_request(debug: false)
      APIRequest.new(
        credential: self,
        method: "GET",
        endpoint: "runs",
        debug:
      )
    end
  end
end
