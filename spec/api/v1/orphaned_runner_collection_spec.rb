require "rails_helper"
include APIAuthenticationHelper

describe "Orphaned runners", type: :request do
  let!(:user) { create(:user, super_admin: true) }

  before do
    allow(Runner).to receive(:destroy_orphaned).and_return(true)
  end

  it "returns a 204 response when orphaned runners are successfully destroyed" do
    delete(
      api_v1_orphaned_runner_collection_path,
      headers: api_authorization_headers(user)
    )

    expect(response).to have_http_status(204)
  end
end
