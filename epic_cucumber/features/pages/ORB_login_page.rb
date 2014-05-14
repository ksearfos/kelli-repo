class ORBLoginPage
  attr_accessor :user_name, :password, :log_on_button

  URL = "http://orb3.ds.ohnet/Physician/Login.aspx"

  def initialize(browser)
    @browser = browser
    @username = @browser.text_field(:name => "ctl00$MainContent$AdamLogin$txtUserName")
    @password = @browser.text_field(:name => "ctl00$MainContent$AdamLogin$txtPassword")
    @log_on_button = @browser.input(:name => "ctl00$MainContent$AdamLogin$btnLogin")
  end

  def visit
    @browser.goto URL
  end

  def login_with(username, password)
    @username.set username
    @password.set password
    @log_on_button.click
    orb_landing_page = ORBLandingPage.new(@browser)
    orb_landing_page
  end
end