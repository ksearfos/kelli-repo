TEST_DATA_DIR = "./features/test_data"
 
if ENV["HEADLESS"] then
  require "celerity"
  browser = Celerity::Browser.new
  INDEX_OFFSET = 0
  WEBDRIVER = false
else
  require 'watir-webdriver'
  browser = Watir::Browser.new :firefox
  INDEX_OFFSET = -1
  WEBDRIVER = true
end
 
Before do
  @browser = browser
  # Navigate to the CareConnect web page
  @ccweb_login_page = CareConnectLoginPage.new(@browser)
  @ccweb_login_page.visit

  # Enter credentials to log in
  print "OPID:   "
  $stdout.flush
  @username = gets.chomp
  print "Password:   "
  $stdout.flush
  @password = STDIN.noecho(&:gets).chomp
  print "\n" # Move console output off password line

  # Log in and open Epic
  @ccweb_landing_page = @ccweb_login_page.login_with @username, @password
  @ccweb_landing_page.epic_link.click
  sleep 15
  window = RAutomation::Window.new(:title => /Hyperspace/i, :adapter => :ms_uia)
  window.exists?.should be_true
  window.send_keys @username
  window.move_mouse 400, 375
  window.click_mouse
  @password.scan(/./).each do |c|
    c = :add if c == "+"
    window.send_keys c
  end
  window.move_mouse 400, 400
  window.click_mouse
  window.click_mouse
  window.move_mouse 725, 525
  window.click_mouse
end
 
at_exit do
  browser.close
end
