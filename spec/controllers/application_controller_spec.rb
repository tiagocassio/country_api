require "rails_helper"

module V1
  class DammitController < ApplicationController; end
end

RSpec.describe ApplicationController, type: :controller do
  controller(V1::DammitController) do
    def index
      render json: { message: "ok" }
    end
  end

  let(:session_record) { create(:session) }
  let(:token) { session_record.signed_id }

  before do
    allow(Session).to receive(:find_signed).with(token).and_return(session_record)
    routes.draw { get "index", controller: "v1/dammit", action: "index" }
  end

  describe "before_action :set_current_request_details" do
    before do
      allow(Current).to(receive(:user_agent).and_return("User Agent"))
      allow(Current).to(receive(:ip_address).and_return("127.0.0.1"))
    end

    it "sets Current.user_agent and Current.ip_address" do
      request.headers['Authorization'] = "Bearer #{token}"
      get :index
      expect(Current.user_agent).to eq("User Agent")
      expect(Current.ip_address).to eq("127.0.0.1")
    end
  end

  describe "before_action :authenticate" do
    context "with valid token" do
      it "sets Current.session" do
        request.headers['Authorization'] = "Bearer #{token}"
        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid token" do
      before do
        allow(Session).to receive(:find_signed).and_return(nil)
        request.headers['Authorization'] = "Bearer invalid"
      end

      it "renders unauthorized error" do
        get :index
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq(I18n.t('helpers.errors.unauthorized'))
      end
    end

    context "without token" do
      it "renders unauthorized error" do
        get :index
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq(I18n.t('helpers.errors.unauthorized'))
      end
    end
  end
end
