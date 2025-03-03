class TestSuiteRunsController < ApplicationController
  def create
    test_suite_run = TestSuiteRun.find(params[:test_suite_run_id])
    authorize test_suite_run

    StartTestSuiteRunJob.perform_later(test_suite_run.id)
    test_suite_run.cache_status("Running")

    redirect_to project_build_path(id: test_suite_run.id, project_id: test_suite_run.project.id)
  end
end
