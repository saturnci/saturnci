# frozen_string_literal: true

class ProjectComponent < ViewComponent::Base
  renders_one :body

  def initialize(project)
    @project = project
  end
end
