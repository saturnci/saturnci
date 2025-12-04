class RunWorker < ApplicationRecord
  belongs_to :task
  alias_method :run, :task
  alias_method :run=, :task=
  belongs_to :worker
end
