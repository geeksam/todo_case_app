require 'spec_helper'
require 'models/request_authorizer'

describe RequestAuthorizer do
  let(:users_collection) {
    stub('Users', get_user: user)
  }

  let(:user) {
    stub('User', verify_password!: nil, user_id: 'nobody@example.com')
  }

  let(:subject) {
    RequestAuthorizer.new(users_collection, permission_list_builder)
  }

  let(:credentials) {
    stub(user_id: 'nobody@example.com', password: 'nobodypassword')
  }

  let(:permission_list_builder) {
    stub('PermissionList Class', new: permissions)
  }

  let(:permissions) {
    stub('PermissionList', has_permission?: true)
  }

  it 'does not raise any exceptions if the authenticated user has the specified permission' do
    ->{ subject.verify!(:some_permission, credentials) } \
      .should_not raise_error
  end

  it 'raises a NotAuthorized exception if the authentication credentials do not match an existing user' do
    users_collection.should_receive(:get_user) \
      .with('nobody@example.com') \
      .and_raise(Exceptions::NotFound)

    ->{ subject.verify!(:some_permission, credentials) } \
      .should raise_error(Exceptions::NotAuthorized, "Authentication failed for user 'nobody@example.com'.")
  end

  it "raises a NotAuthorized exception if the authentication credentials do not match the user's password" do
    user.should_receive(:verify_password!) \
      .with('nobodypassword') \
      .and_raise(Exceptions::PasswordIncorrect)
    ->{ subject.verify!(:some_permission, credentials) } \
      .should raise_error(Exceptions::NotAuthorized, "Authentication failed for user 'nobody@example.com'.")
  end

  it 'raises a NotAuthorized exception if the authenticated user does not have the specified permission' do
    permission_list_builder.should_receive(:new) \
      .with(user) \
      .and_return(permissions)
    permissions.should_receive(:has_permission?) \
      .with(:some_permission) \
      .and_return(false)
    ->{ subject.verify!(:some_permission, credentials) } \
      .should raise_error(Exceptions::NotAuthorized, "Authorization failed; user 'nobody@example.com' does not have 'some_permission' permission.")
  end
end
