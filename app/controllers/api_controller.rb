class ApiController < ActionController::Base
  def create_new_user
    email, password = params.values_at(:email, :password)
    @result = UseCases::CreateNewUser.run_use_case(request_credentials, email, password)
    render_result
  end

  private

  def request_credentials
    BasicAuthCredentials.new(request.headers['HTTP_AUTHORIZATION'])
  end

  def render_result
    case @result.status
      when :unauthorized
        response.headers['WWW-Authenticate'] = 'Basic realm="TodoCaseApp"'
        render nothing: true, status: 401
      when :invalid
        render json: @result.errors, status: 403
      when :success
        render json: @result.response_data, status: 201
      else
        raise "Did not expect a #{@result.status} result status!"
    end
  end
end
