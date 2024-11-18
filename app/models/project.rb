class Project < ApplicationRecord
  has_many :builds, dependent: :destroy
  has_many :jobs, through: :builds
  has_many :runs, through: :builds
  has_many :project_secrets
  belongs_to :user
  belongs_to :saturn_installation

  def to_s
    name
  end
end
