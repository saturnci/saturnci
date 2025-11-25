module Admin
  class TestRunnerAssignmentsController < ApplicationController
    def index
      @test_runner_assignments = TestRunnerAssignment.order("created_at desc")
      authorize :admin, :index?
    end
  end
end
