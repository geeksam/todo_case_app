require 'kookaburra/json_api_driver'
require 'base64'

module TodoCaseApp
  module TestSupport
    class ApiDriver < Kookaburra::JsonApiDriver
      def create_user(data)
        self.username = 'kookaburra'
        self.password = 'cucumbersFTW!'
        post '/api/create_new_user', data
      end
    end
  end
end
