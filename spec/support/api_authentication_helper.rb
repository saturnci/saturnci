module APIAuthenticationHelper
  def api_authorization_headers(user)
    encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials(user.id, user.api_token)
    { "Authorization" => encoded_credentials }
  end
end
