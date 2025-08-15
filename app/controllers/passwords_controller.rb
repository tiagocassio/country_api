class PasswordsController < ApplicationController
  before_action :set_user

  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_content
    end
  end

  private

  def set_user
    @user = Current.user
    render json: { error: "Unauthorized" }, status: :unauthorized unless @user
  end

  def user_params
    params.permit(:password, :password_confirmation)
  end
end
