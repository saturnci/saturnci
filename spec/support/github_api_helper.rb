module GitHubAPIHelper
  extend RSpec::Mocks::ExampleMethods

  def self.mock_api(user)
    fake_github_client = double()
    allow(fake_github_client).to receive(:user).at_least(:once)
    allow(user).to receive(:github_client).and_return(fake_github_client).at_least(:once)
    allow(user).to receive(:can_access_repository?).and_return(true).at_least(:once)
  end
end
