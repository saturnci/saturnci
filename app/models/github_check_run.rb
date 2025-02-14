class GitHubCheckRun < ApplicationRecord
  belongs_to :build

  def start!(github_client:)
    response = github_client.create_check_run(
      build.project.github_repo_full_name,
      "SaturnCI",
      build.commit_hash,
      status: "in_progress",
      started_at: Time.now.iso8601
    )

    update!(github_check_run_id: response.id)
  end

  def finish!
    github_client.update_check_run(
      build.project.github_repo_full_name,
      build.github_check_run_id,
      status: "completed",
      conclusion: build.passed? ? "success" : "failure",
      completed_at: Time.now.iso8601
    )
  end

  private

  def github_client
    build.project.github_account.installation_access_octokit_client
  end
end
