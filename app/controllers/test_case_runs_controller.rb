class TestCaseRunsController < ApplicationController
  def show
    @test_case_run = TestCaseRun.find(params[:id])
    authorize @test_case_run

    @build = @test_case_run.run.build

    @build_component = BuildComponent.new(
      build: @build,
      current_tab_name: "overview",
      branch_name: params[:branch_name],
      statuses: params[:statuses],
      clear: params[:clear]
    )
  end
end
