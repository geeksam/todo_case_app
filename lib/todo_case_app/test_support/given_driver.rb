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

      def current_user
        mental_model.context[:current_user]
      rescue Kookaburra::UnknownKeyError
        mental_model.context[:current_user] = create_user
      end

      def create_user
        uuid = `uuidgen`.strip
        email = "test-user-#{uuid}@example.com"
        password = "Test user password!"
        api.create_user(:email => email, :password => password)
      end
    end
  end
end
