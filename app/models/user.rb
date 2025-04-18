require "octokit"

class User < ApplicationRecord
  acts_as_paranoid
  has_many :repositories
  has_many :projects
  has_many :runs, through: :projects
  has_many :github_accounts
  has_many :github_oauth_tokens
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

  def github_client
    @github_client ||= Octokit::Client.new(access_token: github_oauth_token)
  end

  def github_oauth_token
    github_oauth_tokens.order(created_at: :desc).first.value
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
