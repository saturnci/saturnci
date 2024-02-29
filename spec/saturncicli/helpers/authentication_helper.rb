module AuthenticationHelper
  def self.stub_authentication_request
    WebMock.stub_request(:get, "#{SaturnCICLI::Client::DEFAULT_HOST}/api/v1/builds")
      .to_return(body: "[]", status: 200)
  end
end
