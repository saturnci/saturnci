class AccessToken < ApplicationRecord
  encrypts :value, deterministic: true
  has_secure_token :value
end
