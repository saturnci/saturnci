module Admin
  class WorkerAssignmentsController < ApplicationController
    def index
      @worker_assignments = WorkerAssignment.order("created_at desc")
      authorize :admin, :index?
    end
  end
end
