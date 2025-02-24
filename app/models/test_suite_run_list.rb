class TestSuiteRunList
  def initialize(project, branch_name:, statuses:)
    @project = project
    @branch_name = branch_name
    @statuses = statuses
  end

  def builds
    builds = @project.builds.order("created_at desc").limit(20)

    if @branch_name.present?
      builds = builds.where(branch_name: @branch_name)
    end

    if @statuses.present?
      builds = builds.where("cached_status in (?)", @statuses)
    end

    builds
  end
end
