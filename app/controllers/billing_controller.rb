class BillingController < ApplicationController
  def index
    @project = Project.find(params[:project_id])

    @jobs = BillingReport.new(
      project: @project,
      year: params[:year] || Time.current.year,
      month: params[:month] || Time.current.month
    ).jobs

    @billing_navigation_component = BillingNavigationComponent.new(project: @project)
  end
end
