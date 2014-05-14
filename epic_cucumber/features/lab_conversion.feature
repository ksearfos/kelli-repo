Feature: Lab Conversion
  As a provider, I need lab data
  in my GUI

  Scenario: Lab report converted to new GUI
    Given a lab report exists in ORB
    When I look for it in Epic
    Then I see the lab report in Epic