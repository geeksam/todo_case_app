require 'spec_helper'
require 'models/registered_users'

describe RegisteredUsers do
  def stub_user(name, stub_methods = {})
    uuid = `uuidgen`.strip
    default_stub_methods = {:email => "nobody-#{uuid}@example.com", :kind_of? => true}
    stub_methods = default_stub_methods.merge(stub_methods)
    stub(name, stub_methods)
  end

  let(:subject) {
    RegisteredUsers.new(user_type)
  }

  let(:user_type) {
    Class.new
  }

  it 'provides a list of all registered users that have been added' do
    user_a = stub_user('User A')
    user_b = stub_user('User B')
    subject << user_a
    subject << user_b
    subject.all.should =~ [user_a, user_b]
  end

  it 'gets a user from the list by email address' do
    user_a = stub_user('User A', email: 'nobody_a@example.com')
    user_b = stub_user('User A', email: 'nobody_b@example.com')
    user_c = stub_user('User A', email: 'nobody_c@example.com')
    subject << user_a
    subject << user_b
    subject << user_c
    subject.get_user('nobody_b@example.com').should == user_b
  end

  it 'raises NotFound if there is no user with the specified email address' do
    ->{ subject.get_user('nobody@example.com') } \
      .should raise_error(Exceptions::NotFound, "RegisteredUsers does not contain a user with email 'nobody@example.com'")
  end

  it 'raises RepositoryInsertionFailed if you attempt to add a user with a duplicate email address' do
    subject << stub_user('User A', email: 'nobody@example.com')
    ->{ subject << stub_user('User B', email: 'nobody@example.com') } \
      .should raise_error(Exceptions::RepositoryInsertionFailed, "There is already a user with email 'nobody@example.com' in RegisteredUsers")
  end

  it 'raises RepositoryInsertionFailed if you attempt to add an object that is not a kind of User' do
    user = stub_user('User A')
    user.should_receive(:kind_of?).with(user_type).and_return(false)
    ->{ subject << user } \
      .should raise_error(Exceptions::RepositoryInsertionFailed, "RegisteredUsers can only contain objects of type #{user_type}")
  end

  it 'has a global instance' do
    a = RegisteredUsers.instance
    b = RegisteredUsers.instance
    a.should be_kind_of(RegisteredUsers)
    a.should === b
  end

  it 'allows new instances (other than the global instance) to be created' do
    global = RegisteredUsers.instance
    subject.should_not === global
  end
end
