def setup(orb_browser, epic_browser, username, password)
  # Navigate to ORB
  orb_login_page = OrbLoginPage.new(orb_browser)
  orb_login_page.visit
  
  # Login to ORB
  orb_landing_page = orb_login_page.login_with username, password
  
  # Navigate to the CareConnect web page
  ccweb_login_page = CareConnectLoginPage.new(epic_browser)
  ccweb_login_page.visit
  
  # Log in to CCWeb
  ccweb_landing_page = ccweb_login_page.login_with username, password
  ccweb_landing_page.epic_link.click # Launch Epic
  sleep 30 # Wait for Epic Hyperspace to start up
  
  # Log in to Epic
  window = RAutomation::Window.new(:title => /Hyperspace/i, :adapter => :ms_uia)
  window.exists?.should be_true # Quit if Epic does not open
  window.send_keys username
  window.move_mouse 400, 375
  window.click_mouse
  password.scan(/./).each do |c| # Handle special character
    c = :add if c == "+"
    window.send_keys c
  end
  window.move_mouse 400, 400
  window.click_mouse
  
  # Get through Epic welcome message screen
  window.click_mouse
  window.move_mouse 725, 525
  window.click_mouse
end