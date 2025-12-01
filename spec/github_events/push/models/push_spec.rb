require "rails_helper"

describe "push" do
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

  context "start test suite runs automatically" do
    let!(:repository) do
      create(
        :repository,
        start_test_suite_runs_automatically_on_git_push: true
      )
    end

    it "starts the test suite run" do
      test_suite_run = create(:test_suite_run, repository:)
      expect(test_suite_run).to receive(:start!)
      push_event.prepare_test_suite_run(test_suite_run)
    end
  end

  context "do not start test suite runs automatically" do
    let!(:repository) do
      create(
        :repository,
        start_test_suite_runs_automatically_on_git_push: false
      )
    end

    it "saves the test suite run" do
      test_suite_run = build(:test_suite_run, repository:)
      expect { push_event.prepare_test_suite_run(test_suite_run) }.to change(TestSuiteRun, :count).by(1)
    end

    it "does not start the test suite run" do
      test_suite_run = build(:test_suite_run, repository:)
      expect(test_suite_run).not_to receive(:start!)
      push_event.prepare_test_suite_run(test_suite_run)
    end
  end
end
