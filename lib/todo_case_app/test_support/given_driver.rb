require 'kookaburra/given_driver'
require 'todo_case_app/test_support/api_driver'

module TodoCaseApp
  module TestSupport
    class GivenDriver < Kookaburra::GivenDriver
      def i_have_a_todo_list(name)
        list = api.create_todo_list(:name => name, :owner => current_user[:email])
        mental_model.todo_lists[name] = list
      end

      private

      def api
        ApiDriver.new(configuration)
      end
    end
  end
end
