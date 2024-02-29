module APIHelper
  def self.stub_body(endpoint, body)
    WebMock.stub_request(:get, "#{SaturnCICLI::Client::DEFAULT_HOST}/#{endpoint}")
      .to_return(body: body, status: 200)
  end
end
