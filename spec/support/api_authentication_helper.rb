module APIAuthenticationHelper
  def api_authorization_headers(user)
    encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials(user.id, user.api_token)
    { "Authorization" => encoded_credentials }
  end

  def test_runner_agents_api_authorization_headers(test_runner)
    encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials(
      test_runner.id,
      test_runner.access_token.value
    )
    { "Authorization" => encoded_credentials }
  end
end
