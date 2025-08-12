class TestSuiteRunMailer < ApplicationMailer
  def completion_notification(test_suite_run)
    @test_suite_run = test_suite_run
    @repository = test_suite_run.repository
    @user = @repository.user

    mail(
      to: @user.email,
      subject: "#{@test_suite_run.status} test suite run for #{@repository.name}"
    )
  end
end
