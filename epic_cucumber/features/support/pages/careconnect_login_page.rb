class CareConnectLoginPage
  include PageObject
  
  attr_accessor :user_name, :password, :log_on_button

  URL = "http://ccweb"

  def initialize(browser)
    @browser = browser
    @username = @browser.text_field(:name => "user")
    @password = @browser.text_field(:name => "password")
    @log_on_button = @browser.link(:name => "btnLogin")
  end

  def visit
    @browser.goto URL
  end

  def login_with(username, password)
    @username.set username
    @password.set password
    @log_on_button.click
    ccweb_landing_page = CareConnectLandingPage.new(@browser)
    ccweb_landing_page.username.wait_until_present if WEBDRIVER
    ccweb_landing_page
  end
end
