class WorkerArchitecture < ApplicationRecord
  validates :slug, presence: true, uniqueness: true
end
