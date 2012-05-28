require 'spec_helper'
require 'models/user'

describe User do
  it 'has an email attribute' do
    u = User.new('nobody@example.com')
    u.email.should == 'nobody@example.com'
  end

  describe 'password verification' do
    let(:user) {
      User.new('nobody@example.com', 'foobar')
    }

    it 'does not raise an exception if the passwords match' do
      ->{ user.verify_password!('foobar') } \
        .should_not raise_error
    end

    it 'raises a PasswordIncorrect exception if the passwords do not match' do
      ->{ user.verify_password!('barfood') } \
        .should raise_error(Exceptions::PasswordIncorrect)
    end

    it 'raises a PasswordIncorrect exception if the password is nil' do
      user = User.new('nobody@example.com', nil)
      ->{ user.verify_password!(nil) } \
        .should raise_error(Exceptions::PasswordIncorrect)
    end

    it 'raises a PasswordIncorrect exception if the password is a blank string' do
      user = User.new('nobody@example.com', '')
      ->{ user.verify_password!('') } \
        .should raise_error(Exceptions::PasswordIncorrect)
    end
  end
end
