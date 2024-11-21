class RunEvent < ApplicationRecord
  self.inheritance_column = :_type_not_used
  belongs_to :run, touch: true

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
