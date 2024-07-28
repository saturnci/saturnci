module Billing
  class JobDecorator < ApplicationDecorator
    CHARGE_RATE = 0.1

    def charge
      return unless charge_cents.present?

      charge_cents / 100.0
    end

    def charge_cents
      return unless duration.present?

      (object.duration * CHARGE_RATE).round
    end
  end
end
