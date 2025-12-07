class TestSuiteRerunsController < ApplicationController
  def create
    original_test_suite_run = TestSuiteRun.find(params[:test_suite_run_id])
    test_suite_run = TestSuiteRerun.create!(original_test_suite_run)
    authorize test_suite_run, :create?
    test_suite_run.start!

    redirect_to repository_test_suite_run_path(test_suite_run.repository, test_suite_run)
  end
end
