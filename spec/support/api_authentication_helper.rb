module APIAuthenticationHelper
  def api_authorization_headers(personal_access_token)
    encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials(
      personal_access_token.user.id,
      personal_access_token.access_token.value
    )
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
