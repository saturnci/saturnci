class TestSuiteRunResultNotification < ApplicationRecord
  belongs_to :test_suite_run
  belongs_to :sent_email

  def self.send_notifications
    TestSuiteRun.needing_notification.each do |test_suite_run|
      email = ::TestSuiteRunMailer.completion_notification(test_suite_run)
      
      ActiveRecord::Base.transaction do
        email.deliver_now

        sent_email = SentEmail.create!(
          to: test_suite_run.repository.user.email,
          subject: email.subject,
          body: email.body.to_s
        )

        TestSuiteRunResultNotification.create!(
          test_suite_run: test_suite_run,
          email: test_suite_run.repository.user.email,
          sent_email: sent_email
        )
      end
    end
  end
end
