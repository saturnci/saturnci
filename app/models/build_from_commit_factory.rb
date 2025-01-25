class BuildFromCommitFactory
  def initialize(commit)
    @commit = commit
  end

  def build
    Build.new(
      branch_name: "main",
      author_name: @commit["commit"]["author"]["name"],
      commit_hash: @commit["sha"],
      commit_message: @commit["commit"]["message"]
    )
  end
end
