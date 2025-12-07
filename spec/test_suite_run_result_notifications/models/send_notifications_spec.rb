require "rails_helper"

describe TestSuiteRunResultNotification do
  let!(:test_suite_run) { create(:test_suite_run, cached_status: "Passed") }

  it "records the sending of the email" do
    expect { TestSuiteRunResultNotification.send_notifications }
      .to change(SentEmail, :count).by(1)
  end

  context "when test suite run has a started_by_user" do
    let!(:started_by_user) { create(:user, email: "starter@example.com") }
    let!(:test_suite_run) { create(:test_suite_run, cached_status: "Passed", started_by_user: started_by_user) }

    it "sends the notification to the started_by_user" do
      TestSuiteRunResultNotification.send_notifications
      expect(SentEmail.last.to).to eq("starter@example.com")
    end
  end

  context "when test suite run does not have a started_by_user" do
    let!(:test_suite_run) { create(:test_suite_run, cached_status: "Passed", started_by_user: nil) }

    it "sends the notification to the repository user" do
      TestSuiteRunResultNotification.send_notifications
      expect(SentEmail.last.to).to eq(test_suite_run.repository.user.email)
    end
  end
end
