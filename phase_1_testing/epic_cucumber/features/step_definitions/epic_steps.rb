require 'highline/import'
require 'rautomation'

Given(/^I am on the (.+)$/) do |page_name|
  @ccweb_login_page = Object.const_get(page_name.gsub(" ","")).new(@browser)
  @ccweb_login_page.visit
end

When(/^I submit my credentials$/) do
  @username = ask("OPID:   ") {|q| q.default = "none"}
  @password = ask("Password:   ") {|q| q.echo = false}
  @ccweb_landing_page = @ccweb_login_page.login_with @username.chomp!, @password.chomp!
end

Then(/^I should be logged in$/) do
  @ccweb_landing_page.username.text.should eq "Logged on as: " + @username
  # Try to interact with 
  @ccweb_landing_page.epic_link.click
  sleep 15
  window = RAutomation::Window.new(:title => /Hyperspace/i, :adapter => :ms_uia)
  window.exists?.should be_true
  
  window.send_keys @username
  window.send_keys :tab
  window.send_keys :enter
  window.send_keys :return
  window.send_keys @password
  window.send_keys :tab
  window.send_keys :return
end
