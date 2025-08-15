class Identity::PasswordResetsController < ApplicationController
  skip_before_action :authenticate

  before_action :set_user, only: :update

  def edit
    head :no_content
  end

  def create
    if @user = User.find_by(email: params[:email], verified: true)
      UserMailer.with(user: @user).password_reset.deliver_later
    else
      render json: { error: I18n.t("errors.messages.user_not_verified") }, status: :bad_request
    end
  end

  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_content
    end
  end

  private

  def set_user
    @user = User.find_by_token_for!(:password_reset, params[:sid])
  rescue StandardError
    render json: { error: I18n.t("errors.messages.reset_password_link_invalid") }, status: :bad_request
  end

  def user_params
    params.permit(:password, :password_confirmation)
  end
end
