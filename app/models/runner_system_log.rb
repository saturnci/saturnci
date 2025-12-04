class RunnerSystemLog < ApplicationRecord
  belongs_to :task
  alias_method :run, :task
  alias_method :run=, :task=
end
