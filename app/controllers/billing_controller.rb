class BillingController < ApplicationController
  def index
    @project = Project.find(params[:project_id])

    year = params[:year].presence || Time.current.year
    month = params[:month].presence || Time.current.month

    @jobs = BillingReport.new(project: @project, year:, month:).jobs
      .map { |job| Billing::JobDecorator.new(job) }

    @dates = @project.jobs
      .select("to_char(jobs.created_at, 'YYYY-MM') as month")
      .order("month desc")
      .map(&:month)
      .uniq
      .map { |month_string| month_string.split("-") }
  end
end
