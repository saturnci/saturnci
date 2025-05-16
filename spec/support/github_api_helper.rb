module GitHubAPIHelper
  extend RSpec::Mocks::ExampleMethods

  def self.mock_api(user)
    allow(user).to receive_message_chain(:github_client, :user)
    allow(user).to receive(:can_access_repository?).and_return(true)
  end
end
