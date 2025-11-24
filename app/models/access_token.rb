class AccessToken < ApplicationRecord
  encrypts :value, deterministic: true
  has_secure_token :value

  has_many :personal_access_tokens, dependent: :destroy
  has_many :users, through: :personal_access_tokens
end
