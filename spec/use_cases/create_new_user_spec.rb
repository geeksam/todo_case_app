require 'spec_helper'
require 'use_cases/create_new_user'

describe UseCases::CreateNewUser do
  describe 'class' do
    it 'provides a convenience method that creates and runs the use case in one method' do
      use_case = mock('UseCases::CreateNewUser')
      UseCases::CreateNewUser.should_receive(:new) \
        .with(:authentication, :input_data) \
        .and_return(use_case)
      use_case.should_receive(:run).and_return(:the_result)
      UseCases::CreateNewUser.run_use_case(:authentication, :input_data) \
        .should == :the_result
    end
  end

  let(:subject) {
    UseCases::CreateNewUser.new('authstring',
                                'nobody@example.com',
                                'nobody password',
                                logger,
                                request_authorizer,
                                users_repository)
  }

  let(:request_authorizer) {
    stub('RequestAuthorization', verify!: nil)
  }

  let(:users_repository) { 
    stub('Repositories::Users', insert: nil)
  }

  let(:logger) {
    stub('Logger', debug: nil, info: nil, warn: nil, error: nil, fatal: nil)
  }

  let(:user) {
    stub('User', to_hash: {:email => 'nobody@example.com'})
  }

  let(:result) {
    subject.run
  }

  before(:each) do
    User.stub!(new: user)
  end

  it 'provides the caller with a result object' do
    result.should be_kind_of(UseCases::CreateNewUser::Result)
  end

  it 'authorizes the request' do
    request_authorizer.should_receive(:verify!) \
      .with(:create_user_via_api, 'authstring')
    subject.run
  end

  context 'the request is not authorized' do
    before(:each) do
      request_authorizer.stub!(:verify!) \
        .and_raise(Exceptions::NotAuthorized.new('an error message'))
    end

    it 'does not create a new user' do
      User.should_receive(:new).never
      subject.run
    end

    it 'sets the result status to :unauthorized' do
      result.status.should == :unauthorized
      subject.run
    end

    it 'logs the authorization failure' do
      logger.should_receive(:info) \
        .with('Authorization Failed (CreateNewUser): an error message')
      subject.run
    end
  end

  it 'makes a new User' do
    User.should_receive(:new) \
      .with('nobody@example.com', 'nobody password')
    subject.run
  end

  shared_examples_for :the_data_is_invalid do
    it 'sets the result status to :invalid' do
      result.status.should == :invalid
    end

    it 'sets the result errors to the reason(s) that the User was rejected' do
      result.errors.should == exception.error_messages
    end

    it 'does not set any response data on the result' do
      result.response_data.should be_nil
    end
  end

  context 'the data is valid' do
    it 'adds the new User to the Users repository' do
      users_repository.should_receive(:insert).with(user)
      subject.run
    end

    context 'and the Users repository accepts the User' do
      it 'sets the result status to :success' do
        result.status.should == :success
      end

      it 'sets the result response_data to the public data attributes of the User' do
        result.response_data.should == user.to_hash
      end
    end

    context 'but the Users repository rejects the User' do
      let(:exception) {
        Exceptions::RepositoryInsertionFailed.new
      }

      before(:each) do
        users_repository.stub!(:insert).and_raise(exception)
        exception.stub!(error_messages: %w(foo bar baz))
      end

      it_behaves_like :the_data_is_invalid
    end
  end

  context 'the data is invalid' do
    let(:exception) {
      Exceptions::DataValidationFailed.new
    }

    before(:each) do
      User.stub!(:new).and_raise(exception)
      exception.stub(error_messages: %w(foo bar baz))
    end

    it 'does not add the User to the Users repository' do
      users_repository.should_receive(:insert).never
      subject.run
    end

    it_behaves_like :the_data_is_invalid
  end
end
