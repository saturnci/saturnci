class BillingNavigationComponent < ViewComponent::Base
  def initialize(repository:)
    @repository = repository
  end

  def dates
    @repository.runs
      .joins(:charge)
      .select("to_char(tasks.created_at, 'YYYY-MM') as month")
      .order("month desc")
      .map(&:month)
      .uniq
      .map { |month_string| month_string.split("-") }
  end
end
