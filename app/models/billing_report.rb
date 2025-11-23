class BillingReport
  def initialize(repository:, year:, month:)
    @repository = repository
    @year = year
    @month = month
  end

  def runs
    @repository.runs
      .joins(:charge)
      .where(created_at: start_date..end_date)
      .order("runs.created_at desc")
  end

  def start_date
    Date.new(@year.to_i, @month.to_i, 1)
  end

  def end_date
    start_date.end_of_month.end_of_day
  end
end
