require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "test output encoding", type: :request do
  let!(:run) { create(:run, :with_test_runner, test_output: "existing content 🚀") }
  let!(:test_runner) { run.test_runner }

  it "handles UTF-8 content with emojis correctly" do
    test_content = "new content with emoji 🎉"
    encoded_content = Base64.encode64(test_content)

    post(
      api_v1_test_runner_agents_run_test_output_path(run_id: run.id),
      params: encoded_content,
      headers: test_runner_agents_api_authorization_headers(test_runner).merge({ "CONTENT_TYPE" => "text/plain" })
    )

    expect(response).to have_http_status(:ok)

    run.reload
    expect(run.test_output).to eq("existing content 🚀new content with emoji 🎉")
    expect(run.test_output.encoding).to eq(Encoding::UTF_8)
  end

  it "handles content that Base64 decodes as ASCII-8BIT" do
    test_content = "test content"
    encoded_content = Base64.encode64(test_content)

    run.update!(test_output: "")

    post(
      api_v1_test_runner_agents_run_test_output_path(run_id: run.id),
      params: encoded_content,
      headers: test_runner_agents_api_authorization_headers(test_runner).merge({ "CONTENT_TYPE" => "text/plain" })
    )

    expect(response).to have_http_status(:ok)
    run.reload
    expect(run.test_output).to eq("test content")
    expect(run.test_output.encoding).to eq(Encoding::UTF_8)
  end
end
