module APIAuthenticationHelper
  def api_authorization_headers(personal_access_token)
    encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials(
      personal_access_token.user.id,
      personal_access_token.access_token.value
    )
    { "Authorization" => encoded_credentials }
  end

  def worker_agents_api_authorization_headers(worker)
    encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials(
      worker.id,
      worker.access_token.value
    )
    { "Authorization" => encoded_credentials }
  end
end
