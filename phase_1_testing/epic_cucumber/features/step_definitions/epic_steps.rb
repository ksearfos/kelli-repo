require 'io/console'
require 'rautomation'

Given(/^I am on the CareConnect Login Page$/) do
  # Action performed in Before of env.rb
end

When(/^I submit my credentials$/) do
  # Action performed in Before of env.rb
end

Then(/^I should be logged in$/) do
  @ccweb_landing_page.username.text.should eq "Logged on as: " + @username
end
