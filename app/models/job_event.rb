class JobEvent < ApplicationRecord
  self.inheritance_column = :_type_not_used
  belongs_to :job, touch: true

  enum :type, [
    :job_machine_ready,
    :job_machine_requested,
    :repository_cloned,
    :job_started,
    :pre_script_started,
    :pre_script_finished,
    :test_suite_started,
    :job_finished,
    :image_build_started,
    :image_build_finished
  ]
end
