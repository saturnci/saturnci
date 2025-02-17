# frozen_string_literal: true

class ErrorMessagesComponent < ViewComponent::Base
  attr_reader :resource

  def initialize(resource:)
    @resource = resource
  end
end
