class GitHubCheckRun
  def initialize(build:)
    @build = build
    @github_client = build.project.github_account.installation_access_octokit_client
  end

  def start!
    response = @github_client.create_check_run(
      @build.project.github_repo_full_name,
      "SaturnCI",
      @build.commit_hash,
      status: "in_progress",
      started_at: Time.now.iso8601
    )
  end
end
