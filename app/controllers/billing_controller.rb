class BillingController < ApplicationController
  def index
    @project = Project.find(params[:project_id])

    @jobs = @project.jobs
      .where(created_at: Time.current.beginning_of_month..Time.current.end_of_month)
      .order("jobs.created_at desc")
      .map { |job| Billing::JobDecorator.new(job) }
  end
end
