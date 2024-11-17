class Charge < ApplicationRecord
  belongs_to :job, foreign_key: "run_id"

  def amount
    amount_cents / 100.0
  end

  def amount_cents
    run_duration * rate
  end
end
