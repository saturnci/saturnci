class SendTestSuiteRunResultNotificationsJob < ApplicationJob
  queue_as :default

  def perform
    TestSuiteRunResultNotification.send_notifications
  end
end
