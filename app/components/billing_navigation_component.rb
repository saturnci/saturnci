# frozen_string_literal: true

class BillingNavigationComponent < ViewComponent::Base
  def initialize(project:)
    @project = project
  end

  def dates
    @project.jobs
      .joins(:charge)
      .select("to_char(jobs.created_at, 'YYYY-MM') as month")
      .order("month desc")
      .map(&:month)
      .uniq
      .map { |month_string| month_string.split("-") }
  end
end
