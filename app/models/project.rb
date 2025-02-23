class Project < ApplicationRecord
  acts_as_paranoid
  has_many :builds, dependent: :destroy
  has_many :runs, through: :builds
  has_many :project_secrets
  belongs_to :user
  belongs_to :github_account

  def to_s
    name
  end
end
