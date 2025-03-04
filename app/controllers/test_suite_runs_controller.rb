class TestSuiteRunsController < ApplicationController
  def create
    test_suite_run = TestSuiteRun.find(params[:test_suite_run_id])
    authorize test_suite_run

    test_suite_run.start!
    redirect_to run_path(test_suite_run.runs.first, "test_output")
  end
end
