class BillingController < ApplicationController
  def index
    @repository = Project.find(params[:project_id] || params[:repository_id])
    authorize @repository, :show?

    @runs = BillingReport.new(
      repository: @repository,
      year: params[:year] || Time.current.year,
      month: params[:month] || Time.current.month
    ).runs

    @billing_navigation_component = BillingNavigationComponent.new(repository: @repository)
  end
end
