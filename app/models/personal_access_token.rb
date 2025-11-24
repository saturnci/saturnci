class PersonalAccessToken < ApplicationRecord
  belongs_to :user
  encrypts :value, deterministic: true
  has_secure_token :value
end
