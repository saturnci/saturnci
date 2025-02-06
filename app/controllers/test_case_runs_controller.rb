class TestCaseRunsController < ApplicationController
  def show
    @test_case_run = TestCaseRun.find(params[:id])
    authorize @test_case_run
  end
end
