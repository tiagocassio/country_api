class SessionsController < ApplicationController
  skip_before_action :authenticate, only: :create

  before_action :set_session, only: %i[ show destroy ]

  def index
    if Current.user
      render json: Current.user.sessions.order(created_at: :desc)
    else
      render json: { error: I18n.t("helpers.errors.unauthorized") }, status: :unauthorized
    end
  end

  def show
    render json: @session
  end

  def create
    if (user = User.authenticate_by(email: params[:email], password: params[:password]))
      @session = user.sessions.create!
      response.set_header "X-Session-Token", @session.signed_id
      render json: {
        session: @session,
        token: @session.signed_id,
        user: user
      }
    else
      render json: { error: I18n.t("helpers.errors.failed_to_authenticate") }, status: :unauthorized
    end
  end

  def destroy
    @session.destroy
    head :no_content
  end

  private

  def set_session
    unless Current.user
      render json: { error: I18n.t("helpers.errors.unauthorized") }, status: :unauthorized
      return
    end

    @session = Current.user.sessions.find(params[:id])
  end
end
