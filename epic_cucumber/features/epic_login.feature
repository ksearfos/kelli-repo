Feature: Epic Login
  As an Epic end-user
  I need access to the Epic system

  Scenario: Successful login
    Given I am on the CareConnect Login Page
    When I submit my credentials
    Then I should be logged in