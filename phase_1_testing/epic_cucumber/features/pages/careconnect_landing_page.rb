class CareConnectLandingPage
  attr_accessor :username

  def initialize(browser)
    @browser = browser
    @username = @browser.span(:id => "username")
  end
end
