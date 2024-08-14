class BuildList
  def initialize(build, branch_name:, statuses:)
    @build = build
    @branch_name = branch_name
    @statuses = statuses
  end

  def builds
    builds = @build.project.builds.order("created_at desc")

    if @branch_name.present?
      builds = builds.where(branch_name: @branch_name)
    end

    if @statuses.present?
      builds = builds.where("cached_status in (?)", @statuses)
    end

    builds
  end
end
