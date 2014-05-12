Feature: Encounter Conversion
  As a provider, I need encounter data
  in my GUI

  Scenario: Encounter converted to new GUI
    Given an encounter exists in ORB
    When look for it in Epic
    Then I see the encounter in Epic