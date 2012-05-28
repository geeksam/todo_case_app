require 'rails_spec_helper'

describe ApiController do
  describe '#create_new_user' do
    let(:use_case_response) {
      stub('UseCases::CreateNewUser::Response', status: :success, response_data: {:foo => 'bar'})
    }

    before(:each) do
      UseCases::CreateNewUser.stub!(run_use_case: use_case_response)
      BasicAuthCredentials.stub!(new: :basic_auth_credentials)
    end

    it 'is mapped to POST /api/create_new_user' do
      {:post => '/api/create_new_user'}.should route_to(controller: 'api', action: 'create_new_user')
    end

    it 'uses basic auth credentials' do
      BasicAuthCredentials.should_receive(:new) \
        .with('encodedcredentialsfromheader') \
        .and_return(:credentials)
      request.env['HTTP_AUTHORIZATION'] = 'encodedcredentialsfromheader'
      post :create_new_user
    end

    it 'performs the create user use case with correct input data' do
      UseCases::CreateNewUser.should_receive(:run_use_case) \
        .with(:basic_auth_credentials, 'nobody@example.com', 'nobody password') \
        .and_return(use_case_response)

      post :create_new_user,
        email: 'nobody@example.com',
        password: 'nobody password',
        crap_data: 'passed to server but not used'
    end

    context 'with valid input data' do
      before(:each) do
        post :create_new_user,
          email: 'nobody@example.com',
          password: 'nobody password'
      end

      it 'renders the use case response response data as JSON' do
        response.content_type.should == 'application/json'
        response.body.should == use_case_response.response_data.to_json
      end

      it 'responds with a 201 status' do
        response.status.should == 201
      end
    end

    context 'when the use case reports that the request is unauthorized' do
      let(:use_case_response) {
        stub('UseCases::CreateNewUser::Response', status: :unauthorized)
      }

      it 'responds with a 401 status' do
        post :create_new_user
        response.status = 401
      end

      it 'requests authentication credentials' do
        post :create_new_user
        response.headers['WWW-Authenticate'].should == 'Basic realm="TodoCaseApp"'
      end
    end

    context 'when the use case reports that the input data is invalid' do
      let(:use_case_response) {
        stub('UseCases::CreateNewUser::Response', status: :invalid, errors: %w(foo bar baz))
      }

      it 'responds with a 403 status' do
        post :create_new_user
        response.status.should == 403
      end

      it 'renders the error messages as JSON' do
        post :create_new_user
        response.content_type.should == 'application/json'
        response.body.should == use_case_response.errors.to_json
      end
    end

    context 'when the use case provides a result with an unanticipated status' do
      let(:use_case_response) {
        stub('UseCases::CreateNewUser::Response', status: :something_unusual, errors: %w(foo bar baz))
      }

      it 'raises an Exception' do
        ->{ post :create_new_user } \
          .should raise_error(RuntimeError, "Did not expect a something_unusual result status!")
      end
    end
  end
end
