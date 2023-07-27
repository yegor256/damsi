Feature: Simple Reporting
  I want to be able to build a report

  Scenario: Help can be printed
    When I run bin/damsi with "-h"
    Then Exit code is zero
    And Stdout contains "--help"

  Scenario: Version can be printed
    When I run bin/damsi with "--version"
    Then Exit code is zero

  Scenario: Simple DFG
    Given I have a "simple.dfg" file with content:
    """
    send :sum, a:10
    send :sum, b:15
    recv :sum do |a, b|
      send :mul, x: (a+b)
    end
    recv :mul do |x|
      send :out, x: x
    end
    """
    When I run bin/damsi simple.dfg
    Then Stdout contains "mul called with [25]"
    And Exit code is zero

