class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?
  after_filter :set_csrf_cookie_for_ng

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :param_missing

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  protected

  def verified_request?
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:password, :password_confirmation, :current_password)
    end
  end

  def record_not_found
    respond_to do |format|
      format.html
      format.json {
        render json: { error: 'NotFound' }, status: :not_found
      }
    end
  end

  def param_missing
    respond_to do |format|
      format.html
      format.json {
        render json: { error: 'ParameterMissing' }, status: :bad_request
      }
    end
  end
end
