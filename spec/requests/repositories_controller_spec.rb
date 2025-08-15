require 'rails_helper'

RSpec.describe RepositoriesController, type: :request do
  describe "GET #index" do
    context "when GitHub token is expired" do
      let(:user) { create(:user) }
      
      before do
        login_as user
        allow_any_instance_of(GitHubClient).to receive(:repositories).and_raise(GitHubTokenExpiredError)
      end

      it "signs the user out and redirects to login" do
        get repositories_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when GitHub returns Octokit::Unauthorized" do
      let(:user) { create(:user) }
      let(:octokit_client) { instance_double(Octokit::Client) }
      
      before do
        login_as user
        Rails.cache.clear
        allow(Octokit::Client).to receive(:new).and_return(octokit_client)
        allow(octokit_client).to receive(:user).and_return({ login: 'test' })
        allow(octokit_client).to receive(:repositories).and_raise(Octokit::Unauthorized)
        allow(octokit_client).to receive(:last_response).and_return(double(rels: {}))
      end

      it "redirects to login" do
        get repositories_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end