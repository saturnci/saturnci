# frozen_string_literal: true

class ProjectComponent < ViewComponent::Base
  renders_one :body

  def initialize(project, extra_css_classes: nil)
    @project = project
    @extra_css_classes = extra_css_classes
  end
end
