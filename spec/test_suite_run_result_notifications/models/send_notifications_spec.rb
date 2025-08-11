require "rails_helper"

describe TestSuiteRunResultNotification do
  let!(:test_suite_run) { create(:test_suite_run) }
  
  it "records the sending of the email" do
    expect { TestSuiteRunResultNotification.send_notifications }
      .to change(SentEmail, :count).by(1)
  end
end
