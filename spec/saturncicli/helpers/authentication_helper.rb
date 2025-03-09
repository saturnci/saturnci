module AuthenticationHelper
  def self.stub_authentication_request
    WebMock.stub_request(:get, "#{SaturnCICLI::Credential::DEFAULT_HOST}/api/v1/test_suite_runs")
      .to_return(body: "[]", status: 200)
  end
end
