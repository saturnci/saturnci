if ENV["DOCKER_ENV"].present?
  Capybara.register_driver :selenium_headless do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--window-size=1400,1400")

    Capybara::Selenium::Driver.new(
      app,
      browser: :remote,
      url: "http://chrome:4444/",
      options: options,
    )
  end

  Capybara.default_driver = :selenium_headless
  Capybara.javascript_driver = :selenium_headless
  Capybara.server_host = "0.0.0.0"
  Capybara.server_port = '3000'
  Capybara.app_host = "http://#{IPSocket.getaddress(Socket.gethostname)}:3000"
  Capybara.always_include_port = true
else
  Capybara.register_driver :selenium_headless do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--window-size=1400,1400")

    unless ENV["SHOW_BROWSER"].present?
      options.add_argument("--headless")
    end

    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end

  Capybara.javascript_driver = :selenium_headless
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium_headless
  end
end
