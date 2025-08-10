require "octokit"

class User < ApplicationRecord
  include Users::GitHubAPI
  acts_as_paranoid
  has_secure_token :api_token

  devise(
    :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :validatable,
    :omniauthable,
    omniauth_providers: [:github]
  )

  attr_accessor :impersonating
  def impersonating?
    impersonating
  end

  def email_required?
    false
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create! do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
    end
  end
end
