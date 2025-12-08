class FailureRerunsController < ApplicationController
  def create
    original_test_suite_run = TestSuiteRun.find(params[:test_suite_run_id])
    authorize original_test_suite_run, :create?

    TestSuiteRun.create!(
      original_test_suite_run.slice(
        :repository,
        :branch_name,
        :commit_hash,
        :commit_message,
        :author_name
      )
    )

    head :ok
  end
end
