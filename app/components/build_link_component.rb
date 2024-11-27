# frozen_string_literal: true

class BuildLinkComponent < ViewComponent::Base
  def initialize(build:, active_build:)
    @build = build
    @active_build = active_build
  end

  def css_class
    @build == @active_build ? "active" : ""
  end

  def id
    "build_link_#{@build.id}"
  end
end
