module APIAuthenticationHelper
  def api_authorization_headers(build)
    encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials(build.id, build.api_token)
    { "Authorization" => encoded_credentials }
  end
end
