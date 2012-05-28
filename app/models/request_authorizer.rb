require 'exceptions/not_authorized'
require 'exceptions/not_found'
require 'exceptions/password_incorrect'

class RequestAuthorizer
  def initialize(users_collection = nil, permission_list_builder = nil)
    @users_collection = users_collection || RegisteredUsers.instance
    @permission_list_builder = permission_list_builder || PermissionList
  end

  def verify!(permission, auth_credentials)
    user = @users_collection.get_user(auth_credentials.user_id)
    user.verify_password!(auth_credentials.password)
    verify_permission!(permission, user)
  rescue Exceptions::NotFound, Exceptions::PasswordIncorrect => e
    raise Exceptions::NotAuthorized, "Authentication failed for user '#{auth_credentials.user_id}'."
  end

  private
  
  def verify_permission!(permission, user)
    permission_list = @permission_list_builder.new(user)
    unless permission_list.has_permission?(permission)
      raise Exceptions::NotAuthorized, "Authorization failed; user '#{user.user_id}' does not have '#{permission}' permission."
    end
  end
end
