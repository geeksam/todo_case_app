require 'exceptions/not_found'
require 'exceptions/repository_insertion_failed'
require 'models/user'

class RegisteredUsers
  def self.instance
    @instance ||= new
  end

  def initialize(user_type = User)
    @user_type = user_type
    @users = []
  end

  def <<(user)
    require_user_type!(user)
    require_unique_email!(user.email)
    @users << user
  end

  def all
    @users
  end

  def get_user(email)
    user = @users.detect { |u|
      u.email == email
    }
    if user.nil?
      raise Exceptions::NotFound, "RegisteredUsers does not contain a user with email '#{email}'"
    end
    user
  end

  private

  def require_unique_email!(email_to_check)
    if @users.detect { |u| u.email == email_to_check }
      raise Exceptions::RepositoryInsertionFailed, "There is already a user with email '#{email_to_check}' in RegisteredUsers"
    end
  end

  def require_user_type!(user)
    unless user.kind_of?(@user_type)
      raise Exceptions::RepositoryInsertionFailed, "RegisteredUsers can only contain objects of type #{@user_type}"
    end
  end
end
