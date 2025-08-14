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
  end
end