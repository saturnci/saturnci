class TestSuiteRunResultNotification < ApplicationRecord
  NOTIFICATION_FEATURE_LAUNCH_DATETIME = "2025-08-11 22:00:00 UTC"

  belongs_to :test_suite_run
  belongs_to :sent_email

  def self.test_suite_runs_needing_notification
    TestSuiteRun
      .left_joins(:test_suite_run_result_notifications)
      .where(test_suite_run_result_notifications: { id: nil })
      .where("test_suite_runs.created_at > ?", NOTIFICATION_FEATURE_LAUNCH_DATETIME)
      .where.not(cached_status: ["Running", "Not Started"])
  end

  def self.send_notifications
    test_suite_runs_needing_notification.each do |test_suite_run|
      message = ::TestSuiteRunMailer.completion_notification(test_suite_run, interested_user(test_suite_run).email)

      ActiveRecord::Base.transaction do
        message.deliver_now

        sent_email = SentEmail.create!(
          to: interested_user(test_suite_run).email,
          subject: message.subject,
          body: message.body.to_s
        )

        TestSuiteRunResultNotification.create!(
          test_suite_run: test_suite_run,
          email: interested_user(test_suite_run).email,
          sent_email: sent_email
        )
      end
    end
  end

  def self.interested_user(test_suite_run)
    test_suite_run.started_by_user || test_suite_run.repository.user
  end
end
