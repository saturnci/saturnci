# frozen_string_literal: true

class BuildFilterComponent < ViewComponent::Base
  def initialize(job:, branch_name:, statuses:, current_tab_name:)
    @job = job
    @branch_name = branch_name
    @statuses = statuses
    @current_tab_name = current_tab_name
  end

  def checked?(status)
    @statuses&.include?(status)
  end

  def branch_names
    @job.build.project.builds.map(&:branch_name).uniq
  end
end
