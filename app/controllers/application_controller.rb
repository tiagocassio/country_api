class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include Pagy::Backend

  before_action :set_current_request_details
  before_action :authenticate

  private

  def authenticate
    session_record = authenticate_with_http_token { |token, _| Session.find_signed(token) }
    return render json: { error: I18n.t("helpers.errors.unauthorized") }, status: :unauthorized if session_record.nil?

    Current.session = session_record
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end
end
