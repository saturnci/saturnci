class BillingNavigationComponent < ViewComponent::Base
  def initialize(project:)
    @project = project
  end

  def dates
    @project.runs
      .joins(:charge)
      .select("to_char(runs.created_at, 'YYYY-MM') as month")
      .order("month desc")
      .map(&:month)
      .uniq
      .map { |month_string| month_string.split("-") }
  end
end
