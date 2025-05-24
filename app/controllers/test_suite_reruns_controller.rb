class TestSuiteRerunsController < ApplicationController
  def create
    original_test_suite_run = TestSuiteRun.find(params[:test_suite_run_id])
    test_suite_run = TestSuiteRerun.create!(original_test_suite_run)
    authorize test_suite_run, :create?
    test_suite_run.start!

    redirect_to test_suite_run.repository
  end
end
