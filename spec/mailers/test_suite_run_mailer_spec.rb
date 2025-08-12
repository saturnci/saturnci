require "rails_helper"

describe TestSuiteRunMailer, type: :mailer do
  describe "completion_notification" do
    let!(:github_account) { create(:github_account, account_name: "acmecorp") }
    let!(:repository) { create(:repository, name: "billing-system", github_account:) }

    let!(:test_suite_run) { create(:test_suite_run, 
      repository: repository,
      cached_status: "Passed",
      commit_hash: "2a5b5d8137005d02c33d474a9c54000c0e5f6c57",
      commit_message: "Enhance test suite run notification email with more details"
    ) }

    it "has a subject which includes status, commit message, and repository name" do
      allow(test_suite_run).to receive(:status).and_return("Passed")
      mail = TestSuiteRunMailer.completion_notification(test_suite_run)
      expect(mail.subject).to eq("Passed: \"Enhance test...\" (2a5b5d8) on acmecorp/billing-system")
    end
  end
end
