Feature: Encounter Conversion
  As a provider, I need encounter data
  in my GUI

  Scenario: Encounter converted to new GUI
    Given an encounter exists in ORB
    When I look for the encounter in Epic
    Then I see the encounter in Epic