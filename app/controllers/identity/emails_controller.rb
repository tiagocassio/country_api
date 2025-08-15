class Identity::EmailsController < ApplicationController
  before_action :set_user

  def update
    unless user_params[:email].present?
      @user.errors.add(:email, "is required")
      return render json: @user.errors, status: :unprocessable_content
    end

    @user.password_challenge = user_params[:password_challenge]

    if @user.update(user_params.except(:password_challenge))
      render_show
    else
      render json: @user.errors, status: :unprocessable_content
    end
  end

  private

  def set_user
    @user = Current.user
  end

  def user_params
    params.permit(:email, :password_challenge).with_defaults(password_challenge: "")
  end

  def render_show
    if @user.email_previously_changed?
      resend_email_verification; render(json: @user)
    else
      render json: @user
    end
  end

  def resend_email_verification
    UserMailer.with(user: @user).email_verification.deliver_later
  end
end
