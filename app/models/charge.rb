class Charge < ApplicationRecord
  belongs_to :job

  def amount
    amount_cents / 100.0
  end

  def amount_cents
    job_duration * rate
  end
end
