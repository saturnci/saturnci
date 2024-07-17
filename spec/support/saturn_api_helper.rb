require "net/http"

module SaturnAPIHelper
  include APIAuthenticationHelper

  def system_log_http_request(job:, body: nil)
    http_request(
      api_authorization_headers:,
      path: api_v1_job_system_logs_path(job_id: job.id, format: :json),
      body:
    )

    # Wait for request to finish
    sleep(0.5)
  end

  def http_request(api_authorization_headers:, path:, body: nil)
    uri = URI("#{Capybara.current_session.server_url}#{path}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    request = Net::HTTP::Post.new(uri.request_uri, api_authorization_headers.merge("Content-Type" => "text/plain"))
    request.body = body
    http.request(request)
  end
end
