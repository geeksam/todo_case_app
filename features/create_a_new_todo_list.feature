@wip
Feature: Create a New Todo List

So that I don't forget the things I need to do rlated to a particular topic,
As someone with a number of outstanding tasks on my plate,
I need to create a list in which I can note each of these tasks.

  Scenario: Main Success
    When I "Sign In"
    And I choose to create a new todo list

    Then the system asks me what I want to call the new todo list

    When I provide a name for the todo list

    Then the system shows the new todo list
    And I see that the todo list is currently empty

  Scenario: Duplicate List Name
    Given I have a todo list named "Groceries Needed"

    When I "Sign In"
    And I choose to create a new todo list

    Then the system asks me what I want to call the new todo list

    When I provide the name "Groceries Needed" for the todo list

    Then the system tells me that I already have a todo list named "Groceries Needed"
    And the system asks me what I want to call the new todo list

    When I provide the name "Daily Chores" for the todo list

    Then the system shows me the "Daily Chores" todo list

  Scenario: Cancel Todo List Creation
    When I "Sign In"
    And I choose to create a new todo list

    Then the system asks me what I want to call the new todo list

    When I choose to cancel out of creating a new todo list

    Then the system returns me to what I was doing before I chose to create a new todo list
