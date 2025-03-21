class GitHubOAuthToken < ApplicationRecord
  belongs_to :user
  encrypts :value
end
