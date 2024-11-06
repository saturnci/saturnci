require "rails_helper"

RSpec.describe "push" do
  let!(:payload) do
    {
      "ref": "refs/heads/main",
      "repository": {
        "id": 123,
        "name": "test",
        "full_name": "user/test",
      },
      "pusher": {
        "name": "user",
      },
      "head_commit": {
        "id": "abc123",
        "message": "commit message",
        "author": {
          "name": "author name",
          "email": "author email",
        },
      },
    }.with_indifferent_access
  end

  let!(:push_event) do
    GitHubEvents::Push.new(payload, "user/test")
  end

  context "start builds automatically" do
    let!(:project) { create(:project, start_builds_automatically_on_git_push: true) }

    it "starts the build" do
      build = Build.new(project:)
      expect(build).to receive(:start!)
      push_event.prepare_build(build)
    end
  end

  context "do not start builds automatically" do
    let!(:project) { create(:project, start_builds_automatically_on_git_push: false) }

    it "saves the build" do
      build = Build.new(project:)
      expect { push_event.prepare_build(build) }.to change(Build, :count).by(1)
    end

    it "does not start the build" do
      build = Build.new(project:)
      expect(build).not_to receive(:start!)
      push_event.prepare_build(build)
    end
  end
end
