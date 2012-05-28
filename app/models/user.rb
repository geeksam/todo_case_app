require 'exceptions/password_incorrect'

class User
  attr_reader :email

  # TODO: password should be encrypted as soon as the user object is
  # created
  def initialize(email, password = nil)
    @email = email
    @password = password
  end

  def verify_password!(check_password)
    unless password_matches?(check_password)
      raise Exceptions::PasswordIncorrect
    end
  end

  private

  def password_matches?(check_password)
    return false if @password.nil?
    return false if @password == ''
    check_password == @password
  end
end
