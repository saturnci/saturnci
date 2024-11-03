class ProjectSecret < ApplicationRecord
  belongs_to :project
  encrypts :value
end
