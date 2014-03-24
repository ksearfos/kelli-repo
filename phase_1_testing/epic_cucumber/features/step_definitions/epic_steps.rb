require 'highline/import'

Given(/^I am on the (.+)$/) do |page_name|
  @ccweb_login_page = Object.const_get(page_name.gsub(" ","")).new(@browser)
  @ccweb_login_page.visit
end

When(/^I submit my credentials$/) do
  @username = ask("OPID:   ") {|q| q.default = "none"}
  password = ask("Password:   ") {|q| q.echo = false}
  @ccweb_landing_page = @ccweb_login_page.login_with @username.chomp!, password.chomp!
end

Then(/^I should be logged in$/) do
  @ccweb_landing_page.username.text.should eq "Logged on as: " + @username
end
