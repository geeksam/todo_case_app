require 'exceptions/not_authorized'
require 'exceptions/data_validation_failed'
require 'exceptions/repository_insertion_failed'
require 'repositories/users'
require 'models/user'

module UseCases
  class CreateNewUser
    Result = Struct.new(:status, :response_data, :errors)

    def self.run_use_case(*args)
      use_case = new(*args)
      use_case.run
    end

    # TODO: use a system configuration object instead of passing in so
    # many optional configuration parameters
    def initialize(request_credentials, email, password, logger = nil, request_authorizer = nil, registered_users = nil)
      @request_credentials = request_credentials
      @email = email
      @password = password
      @logger = logger || Logger.new(STDERR)
      @request_authorizer = request_authorizer || RequestAuthorizer.new
      @registered_users = registered_users || RegisteredUsers.new
    end

    def run
      @request_authorizer.verify!(:create_user_via_api, @request_credentials)
      user = User.new(@email, @password)
      @registered_users.insert(user)
      Result.new(:success, user.to_hash)
    rescue Exceptions::DataValidationFailed, Exceptions::RepositoryInsertionFailed => e
      Result.new(:invalid, nil, e.error_messages)
    rescue Exceptions::NotAuthorized => e
      @logger.info("Authorization Failed (CreateNewUser): #{e.message}")
      Result.new(:unauthorized)
    end
  end
end
