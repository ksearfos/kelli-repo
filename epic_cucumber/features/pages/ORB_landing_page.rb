class ORBLandingPage
  
  URL = "http://orb3.ds.ohnet/Physician/Pages/Home.aspx"
  
  def initialize(browser)
    @browser = browser
  end
  
  def visit
	@browser.goto URL
  end
  
end