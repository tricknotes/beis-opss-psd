class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :authenticate_user!
  skip_before_action :set_current_user
  skip_before_action :set_raven_context
  skip_before_action :has_accepted_declaration
  skip_before_action :authorize_user

  include AuthenticationConcern

  def openid_connect
    request_and_store_token(auth_code, params[:request_path])

    redirect_path = is_relative(params[:request_path]) ? params[:request_path] : root_path
    redirect_to redirect_path
  # rescue RestClient::ExceptionWithResponse => e
    # redirect_to keycloak_login_url(params[:request_path]), alert: signin_error_message(e)
  end

private

  def signin_error_message(error)
    error.is_a?(RestClient::Unauthorized) ? "Invalid email or password." : JSON(error.response)["error_description"]
  end

  def request_and_store_token(auth_code, redirect_url)
    self.keycloak_token = ::KeycloakClient.instance.exchange_code_for_token(auth_code, session_url_with_redirect(redirect_url))
  end

  def auth_code
    params.require(:code)
  end

  def is_relative(url)
    url =~ /^\/[^\/\\]/
  end
end