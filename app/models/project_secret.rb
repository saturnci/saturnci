class ProjectSecret < ApplicationRecord
  belongs_to :project
  encrypts :value
  MASK_VALUE = "X"*20
end
