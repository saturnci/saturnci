require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "test output encoding", type: :request do
  let!(:run) { create(:run, test_output: "existing content 🚀") }
  let!(:user) { run.build.project.user }
  
  it "handles UTF-8 content with emojis correctly" do
    # Content with emoji that would cause encoding issues
    test_content = "new content with emoji 🎉"
    encoded_content = Base64.encode64(test_content)
    
    post(
      api_v1_run_test_output_path(run_id: run.id),
      params: encoded_content,
      headers: api_authorization_headers(user).merge({ "CONTENT_TYPE" => "text/plain" })
    )
    
    expect(response).to have_http_status(:ok)
    
    run.reload
    expect(run.test_output).to eq("existing content 🚀new content with emoji 🎉")
    expect(run.test_output.encoding).to eq(Encoding::UTF_8)
  end
  
  it "handles content that Base64 decodes as ASCII-8BIT" do
    # Regular text that when decoded will be ASCII-8BIT by default
    test_content = "test content"
    # Base64.decode64 returns ASCII-8BIT encoded strings
    encoded_content = Base64.encode64(test_content)
    
    # Clear existing content
    run.update!(test_output: "")
    
    post(
      api_v1_run_test_output_path(run_id: run.id),
      params: encoded_content,
      headers: api_authorization_headers(user).merge({ "CONTENT_TYPE" => "text/plain" })
    )
    
    expect(response).to have_http_status(:ok)
    run.reload
    expect(run.test_output).to eq("test content")
    expect(run.test_output.encoding).to eq(Encoding::UTF_8)
  end
end