class ProjectSecret < ApplicationRecord
  belongs_to :repository, foreign_key: "project_id"
  belongs_to :project
  encrypts :value
  MASK_VALUE = "X"*20
end
