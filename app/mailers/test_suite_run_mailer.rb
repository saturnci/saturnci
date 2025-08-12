class TestSuiteRunMailer < ApplicationMailer
  include ApplicationHelper
  
  def completion_notification(test_suite_run)
    @test_suite_run = test_suite_run
    @repository = test_suite_run.repository
    @user = @repository.user

    @abbreviated_hash = @test_suite_run.commit_hash[0..6]
    truncated_message = @test_suite_run.commit_message.truncate(15)
    
    mail(
      to: @user.email,
      subject: "#{@test_suite_run.status}: " \
               "\"#{truncated_message}\" " \
               "(#{@abbreviated_hash}) " \
               "on #{@repository.github_account.account_name}/#{@repository.name}"
    )
  end
end
