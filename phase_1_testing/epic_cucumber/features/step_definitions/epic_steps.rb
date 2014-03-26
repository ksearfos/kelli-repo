require 'io/console'
require 'rautomation'

Given(/^I am on the (.+)$/) do |page_name|
  @ccweb_login_page = Object.const_get(page_name.gsub(" ","")).new(@browser)
  @ccweb_login_page.visit
end

When(/^I submit my credentials$/) do
  print "OPID:   "
  $stdout.flush
  @username = gets.chomp
  print "Password:   "
  $stdout.flush
  @password = STDIN.noecho(&:gets).chomp
  print "\n" # Move console output off password line
  @ccweb_landing_page = @ccweb_login_page.login_with @username, @password
end

Then(/^I should be logged in$/) do
  @ccweb_landing_page.username.text.should eq "Logged on as: " + @username
  # Try to interact with 
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
