require Rails.root.join("lib/application_decorator")

module Billing
  class RunDecorator < ApplicationDecorator
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
