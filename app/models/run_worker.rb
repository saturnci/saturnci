class RunWorker < ApplicationRecord
  belongs_to :run
  belongs_to :worker
end
