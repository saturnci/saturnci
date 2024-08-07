module Billing
  class JobDecorator < ApplicationDecorator
    def charge
      return unless charge_cents.present?

      charge_cents / 100.0
    end

    def charge_cents
      return unless duration.present?

      (object.duration * Rails.configuration.charge_rate).round
    end
  end
end
