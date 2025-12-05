class WorkerArchitecture < ApplicationRecord
  TERRA_SLUG = "terra"
  NOVA_SLUG = "nova"

  validates :slug, presence: true, uniqueness: true

  def self.terra
    find_by!(slug: TERRA_SLUG)
  end

  def self.nova
    find_by!(slug: NOVA_SLUG)
  end
end
