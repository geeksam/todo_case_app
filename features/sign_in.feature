@wip
Feature: Sign In

So that I can access my todo lists and tasks,
As a registered user,
I must authenticate myself to the system.

  Scenario: No Todo Lists
    Given I have not created a todo list

    When I launch the application

    Then the system asks for my email address and password

    When I provide my correct email address and password

    Then the system shows me the "My Tasks" todo list
    And I see that the todo list is currently empty

  Scenario: One Todo List
    Given I have a todo list named "Groceries Needed"

    When I launch the application

    Then the system asks for my email address and password

    When I provide my correct email address and password

    Then the system shows me the "Groceries Needed" todo list

  Scenario: Multiple Todo Lists
    Given I have a todo list named "Groceries Needed"
    And I have a todo list named "People to Fire"
    And I have a todo list named "Countries to Visit"
    And I have most recently viewed the "People to Fire" todo list

    When I launch the application

    Then the system asks for my email address and password

    When I provide my correct email address and password

    Then the system shows me the "People to Fire" todo list

  Scenario: Invalid Credentials
    When I launch the application

    Then the system asks for my email address and password

    When I provide and incorrect email or password

    Then the system tells me it could not authenticate me
    And the system asks for my email address and password
    And the system does not display any todo list

  Scenario: Explicitely Load a Todo List
    Given I have a todo list named "Groceries Needed"
    And I have a todo list named "People to Fire"
    And I have a todo list named "Countries to Visit"
    And I have most recently viewed the "People to Fire" todo list

    When I launch the application by explicitely viewing the "Groceries Needed" todo list

    Then the system asks for my email address and password
    And the system does not display any todo list
    
    When I provide my correct email address and password

    Then the system shows me the "Groceries Needed" todo list
