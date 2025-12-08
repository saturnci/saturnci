class TestSuiteRunFinish
  def initialize(task)
    @task = task
  end

  def process
    ActiveRecord::Base.transaction do
      @task.finish!
      @task.worker.worker_events.create!(type: :test_run_finished)

      if @task.test_suite_run.tasks.all?(&:finished?)
        @task.test_suite_run.check_test_case_run_integrity!
        TestSuiteRunLinkComponent.refresh(@task.test_suite_run)
        GitHubCheckRun.find_by(test_suite_run: @task.test_suite_run)&.finish!
      end
    end

    Nova::DeleteK8sJobJob.perform_later(@task.worker.name)
  end
end
