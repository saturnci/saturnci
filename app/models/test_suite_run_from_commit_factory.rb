class TestSuiteRunFromCommitFactory
  def initialize(commit)
    @commit = commit
  end

  def test_suite_run
    TestSuiteRun.new(
      branch_name: "main",
      author_name: @commit["commit"]["author"]["name"],
      commit_hash: @commit["sha"],
      commit_message: @commit["commit"]["message"]
    )
  end

  def self.most_recent_commit(project)
    client = project.github_account.installation_access_octokit_client
    client.commit(project.github_repo_full_name, "main")
  end
end
