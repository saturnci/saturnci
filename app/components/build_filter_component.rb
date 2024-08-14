# frozen_string_literal: true

class BuildFilterComponent < ViewComponent::Base
  def initialize(job:, build_list:, statuses:, current_tab_name:)
    @job = job
    @build_list = build_list
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
