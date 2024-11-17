class JobEvent < ApplicationRecord
  self.table_name = "run_events"
  self.inheritance_column = :_type_not_used
  belongs_to :job, touch: true, foreign_key: "run_id"

  enum :type, [
    :image_build_started,
    :image_build_finished,
    :job_machine_requested,
    :job_machine_ready,
    :job_started,
    :job_finished,
    :pre_script_started,
    :pre_script_finished,
    :test_suite_started,
    :repository_cloned,
    :job_cancelled,
  ]
end
