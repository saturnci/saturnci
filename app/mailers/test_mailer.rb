class TestMailer < ApplicationMailer
  def hello_world
    mail(
      to: "jason@saturnci.com",
      subject: "Hello World from SaturnCI"
    ) do |format|
      format.text { render plain: "This is a test email from SaturnCI. If you're seeing this, Postmark is working!" }
      format.html { render html: "<p>This is a test email from SaturnCI. If you're seeing this, <strong>Postmark is working!</strong></p>".html_safe }
    end
  end
end