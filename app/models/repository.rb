class Repository < ApplicationRecord
  acts_as_paranoid
  has_many :builds
  has_many :test_suite_runs, dependent: :destroy, foreign_key: "project_id"
  has_many :runs, through: :test_suite_runs
  has_many :project_secrets, foreign_key: "project_id"
  belongs_to :user
  belongs_to :github_account

  def to_s
    name
  end
end
