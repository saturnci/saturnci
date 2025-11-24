class PersonalAccessToken < ApplicationRecord
  belongs_to :user
  encrypts :value
  has_secure_token :value
end
