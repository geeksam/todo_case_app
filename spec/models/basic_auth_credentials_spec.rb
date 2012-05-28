require 'spec_helper'
require 'models/basic_auth_credentials'

describe BasicAuthCredentials do
  def basic_auth_header(user_id, password)
    encoded_part = Base64.encode64("#{user_id}:#{password}")
    "Basic #{encoded_part}"
  end

  it 'turns an HTTP Basic Auth "Authorization" header into a user_id and a password' do
    header = basic_auth_header('nobody@example.com', 'This is my password!')
    credentials = BasicAuthCredentials.new(header)
    credentials.user_id.should == 'nobody@example.com'
    credentials.password.should == 'This is my password!'
  end

  it 'gives a nil user_id and password if initialized with nil' do
    credentials = BasicAuthCredentials.new(nil)
    credentials.user_id.should == nil
    credentials.password.should == nil
  end

  it 'gives a nil user_id and password if initialized with a blank string' do
    credentials = BasicAuthCredentials.new('')
    credentials.user_id.should == nil
    credentials.password.should == nil
  end

  it 'can handle a password that has a colon in it' do
    header = basic_auth_header('nobody@example.com', 'password:with:colons')
    credentials = BasicAuthCredentials.new(header)
    credentials.user_id.should == 'nobody@example.com'
    credentials.password.should == 'password:with:colons'
  end
end
