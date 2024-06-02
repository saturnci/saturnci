require "rails_helper"
require "net/http"

describe "Streaming", type: :system do
  include APIAuthenticationHelper
  let!(:job) { create(:job) }

  before do
    login_as(job.build.project.user, scope: :user)
  end

  it "streams" do
    visit job_detail_content_project_build_job_path(
      job.build.project,
      job.build,
      job,
      "system_logs"
    )

    # Get the Capybara server host and port
    server_url = Capybara.current_session.server_url
    uri = URI("#{server_url}#{api_v1_job_system_logs_path(job_id: job.id, format: :json)}")

    # Simulate updating the job's system logs via the API using Net::HTTP
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    request = Net::HTTP::Post.new(uri.request_uri, api_authorization_headers.merge("Content-Type" => "text/plain"))
    request.body = "new log content"
    http.request(request)

    # Assert that the updated contents appear on the page without refreshing
    expect(page).to have_content("new log content", wait: 10)
  end
end
