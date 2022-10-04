Feature: Modulops deploywarn
  Using modulops, I want to be able to warn a team after deployment

  Scenario: Emails are sent for known project with valid emails
    Given the mandrill API key exists
    And a file named ".modulops_database.json" with:
    """
    {
      "deploywarn": {
        "test": ["a@test.test"]
      }
    }
    """
    And the mandrill response is valid
    And the mandrill API key is valid
    When I successfully run `modulops deploywarn test`
    Then the output should contain "Ok!"

  Scenario: Emails are not sent for known project with invalid emails
    Given the mandrill API key exists
    And a file named ".modulops_database.json" with:
    """
    {
      "deploywarn": {
        "test": ["foo@bar.baz"]
      }
    }
    """
    And the mandrill response is invalid
    And the mandrill API key is valid
    When I successfully run `modulops deploywarn test`
    Then the output should contain "Emails were not sent to foo@bar.baz"

  Scenario: Emails are not sent for unknown project
    Given the mandrill API key exists
    And a file named ".modulops_database.json" with:
    """
    {
      "deploywarn": {
        "test": ["a@test.test"]
      }
    }
    """
    And the mandrill response is valid
    And the mandrill API key is valid
    When I successfully run `modulops deploywarn plop`
    Then the output should contain "No emails for project plop"

  Scenario: Emails are not sent for invalid key
    Given the mandrill API key exists
    And a file named ".modulops_database.json" with:
    """
    {
      "deploywarn": {
        "test": ["a@test.test"]
      }
    }
    """
    When I successfully run `modulops deploywarn test`
    Then the output should contain "No emails were sent:"

  Scenario: Emails are not sent when no key is given
    And a file named ".modulops_database.json" with:
    """
    {
      "deploywarn": {
        "test": ["a@test.test"]
      }
    }
    """
    When I successfully run `modulops deploywarn test`
    Then the output should contain "No Mandrill API Key given"

  Scenario: By default, search configuration in home directory
    When I successfully run `modulops deploywarn test`
    Then the output should contain "No configuration found at /app/tmp/aruba/.modulops_database.json"

  Scenario: Search configuration in given path
    Given the configuration path is '/app/plop/test.json'
    When I successfully run `modulops deploywarn test`
    Then the output should contain "No configuration found at /app/plop/test.json"
