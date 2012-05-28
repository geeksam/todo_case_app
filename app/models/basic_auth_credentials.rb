require 'base64'

class BasicAuthCredentials
  attr_reader :user_id, :password

  def initialize(encoded_credentials)
    encoded_credentials ||= ''
    encoded_credentials.sub!(/^Basic\s+/, '')
    decoded = Base64.decode64(encoded_credentials)
    @user_id, @password = decoded.split(':', 2)
  end
end
