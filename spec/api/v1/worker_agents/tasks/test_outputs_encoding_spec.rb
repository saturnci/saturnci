require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "test output encoding", type: :request do
  let!(:task) { create(:run, :with_worker, test_output: "existing content 🚀") }
  let!(:worker) { task.worker }

  it "handles UTF-8 content with emojis correctly" do
    test_content = "new content with emoji 🎉"
    encoded_content = Base64.encode64(test_content)

    post(
      api_v1_worker_agents_task_test_output_path(task_id: task.id),
      params: encoded_content,
      headers: worker_agents_api_authorization_headers(worker).merge({ "CONTENT_TYPE" => "text/plain" })
    )

    expect(response).to have_http_status(:ok)

    task.reload
    expect(task.test_output).to eq("existing content 🚀new content with emoji 🎉")
    expect(task.test_output.encoding).to eq(Encoding::UTF_8)
  end

  it "handles content that Base64 decodes as ASCII-8BIT" do
    test_content = "test content"
    encoded_content = Base64.encode64(test_content)

    task.update!(test_output: "")

    post(
      api_v1_worker_agents_task_test_output_path(task_id: task.id),
      params: encoded_content,
      headers: worker_agents_api_authorization_headers(worker).merge({ "CONTENT_TYPE" => "text/plain" })
    )

    expect(response).to have_http_status(:ok)
    task.reload
    expect(task.test_output).to eq("test content")
    expect(task.test_output.encoding).to eq(Encoding::UTF_8)
  end
end
