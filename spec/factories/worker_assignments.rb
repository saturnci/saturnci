FactoryBot.define do
  factory :worker_assignment do
    run

    after(:build) do |worker_assignment|
      worker_assignment.worker ||= build(:worker, task: worker_assignment.run)
    end

    after(:create) do |worker_assignment|
      worker_assignment.worker.update!(task: worker_assignment.run) unless worker_assignment.worker.task_id.present?
    end
  end
end
