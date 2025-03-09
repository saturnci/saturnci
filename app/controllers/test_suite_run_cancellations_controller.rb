class TestSuiteRunCancellationsController < ApplicationController
  def create
    test_suite_run = TestSuiteRun.find(params[:test_suite_run_id])
    authorize test_suite_run, :destroy?
    test_suite_run.cancel!

    redirect_to test_suite_run.project
  end
end
