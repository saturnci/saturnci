module SaturnAPIHelper
  def http_request(api_authorization_headers:, path:, body:)
    uri = URI("#{Capybara.current_session.server_url}#{path}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    request = Net::HTTP::Post.new(uri.request_uri, api_authorization_headers.merge("Content-Type" => "text/plain"))
    request.body = body
    http.request(request)
  end
end
