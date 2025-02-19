class BuildFilterComponent < ViewComponent::Base
  def initialize(build:, branch_name:, checked_statuses:, current_tab_name:)
    @build = build
    @branch_name = branch_name
    @checked_statuses = checked_statuses
    @current_tab_name = current_tab_name
  end

  def checked?(status)
    @checked_statuses&.include?(status)
  end

  def branch_names
    @build.project.builds.map(&:branch_name).uniq
  end
end
