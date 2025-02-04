module APIHelper
  def self.stub_body(endpoint, body)
    WebMock.stub_request(:get, "#{SaturnCICLI::Credential::DEFAULT_HOST}/#{endpoint}")
      .to_return(body: body.to_json, status: 200)
  end
end
