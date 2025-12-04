class TaskEvent < ApplicationRecord
  self.table_name = "task_events"
  self.inheritance_column = :_type_not_used
  belongs_to :task, touch: true
  alias_method :run, :task
  alias_method :run=, :task=

  enum :type, [
    :image_build_started,
    :image_build_finished,
    :runner_requested,
    :runner_ready,
    :run_started,
    :run_finished,
    :pre_script_started,
    :pre_script_finished,
    :test_suite_started,
    :repository_cloned,
    :run_cancelled,
  ]
end
