# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }

  before do
    allow(controller).to receive(:authenticate).and_return(true)
    allow(Current).to receive(:user).and_return(user)
  end

  describe 'GET #index' do
    context 'when authenticated' do
      let!(:old_session) { create(:session, user: user, created_at: 1.day.ago) }
      let!(:new_session) { create(:session, user: user, created_at: 1.hour.ago) }

      it 'returns all user sessions' do
        get :index
        sessions = JSON.parse(response.body)
        expect(sessions.length).to eq(2) # old_session and new_session
      end

      it 'orders sessions by created_at desc' do
        get :index
        sessions = JSON.parse(response.body)
        expect(sessions.first['id']).to eq(new_session.id)
        expect(sessions.last['id']).to eq(old_session.id)
      end

      it 'returns success status' do
        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when not authenticated' do
      before do
        allow(Current).to receive(:user).and_return(nil)
      end

      it 'returns unauthorized status' do
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET #show' do
    context 'when authenticated' do
      it 'returns the session' do
        get :show, params: { id: session.id }, format: :json
        expect(response).to have_http_status(:ok)
      end

      it 'returns 404 for non-existent session' do
        expect {
          get :show, params: { id: 99999 }, format: :json
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'returns 404 for session belonging to different user' do
        other_user = create(:user)
        other_session = create(:session, user: other_user)

        expect {
          get :show, params: { id: other_session.id }, format: :json
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when not authenticated' do
      before do
        allow(Current).to receive(:user).and_return(nil)
      end

      it 'returns unauthorized status' do
        get :show, params: { id: session.id }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST #create' do
    context 'with valid credentials' do
      let(:valid_params) do
        {
          email: user.email,
          password: 'password'
        }
      end

      before do
        allow(controller).to receive(:authenticate).and_return(false) # Skip for create action
        allow(User).to receive(:authenticate_by).with(email: user.email, password: 'password').and_return(user)
      end

      it 'creates a new session' do
        expect {
          post :create, params: valid_params, format: :json
        }.to change { user.sessions.count }.by(1)
      end

      it 'sets the X-Session-Token header' do
        post :create, params: valid_params, format: :json
        expect(response.headers['X-Session-Token']).to be_present
      end

      it 'returns success status' do
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid credentials' do
      let(:invalid_params) do
        {
          email: user.email,
          password: 'wrongpassword'
        }
      end

      before do
        allow(controller).to receive(:authenticate).and_return(false) # Skip for create action
        allow(User).to receive(:authenticate_by).with(email: user.email, password: 'wrongpassword').and_return(nil)
      end

      it 'does not create a session' do
        expect {
          post :create, params: invalid_params, format: :json
        }.not_to change { user.sessions.count }
      end

      it 'returns unauthorized status' do
        post :create, params: invalid_params, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns error message' do
        post :create, params: invalid_params, format: :json
        error_response = JSON.parse(response.body)
        expect(error_response['error']).to be_present
      end
    end

    context 'with missing parameters' do
      context 'when email is missing' do
        let(:invalid_params) do
          { password: 'password' }
        end

        before do
          allow(controller).to receive(:authenticate).and_return(false) # Skip for create action
          allow(User).to receive(:authenticate_by).with(email: nil, password: 'password').and_return(nil)
        end

        it 'returns unauthorized status' do
          post :create, params: invalid_params, format: :json
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'when password is missing' do
        let(:invalid_params) do
          { email: user.email }
        end

        before do
          allow(controller).to receive(:authenticate).and_return(false) # Skip for create action
          allow(User).to receive(:authenticate_by).with(email: user.email, password: nil).and_return(nil)
        end

        it 'returns unauthorized status' do
          post :create, params: invalid_params, format: :json
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when authenticated' do
      it 'destroys the session' do
        session.reload
        user.reload

        expect {
          delete :destroy, params: { id: session.id }, format: :json
        }.to change { user.reload.sessions.count }.by(-1)
      end

      it 'returns success status' do
        delete :destroy, params: { id: session.id }, format: :json
        expect(response).to have_http_status(:no_content)
      end

      it 'returns 404 for non-existent session' do
        expect {
          delete :destroy, params: { id: 99999 }, format: :json
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'returns 404 for session belonging to different user' do
        other_user = create(:user)
        other_session = create(:session, user: other_user)

        expect {
          delete :destroy, params: { id: other_session.id }, format: :json
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when not authenticated' do
      before do
        allow(Current).to receive(:user).and_return(nil)
      end

      it 'returns unauthorized status' do
        delete :destroy, params: { id: session.id }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'authentication' do
    it 'skips authentication for create action' do
      allow(Current).to receive(:user).and_return(nil)

      expect { post :create, params: { email: 'test@example.com', password: 'password' } }.not_to raise_error
    end

    it 'requires authentication for other actions' do
      expect(controller.class._process_action_callbacks.map(&:filter)).to include(:authenticate)
    end
  end

  describe 'before_action :set_session' do
    it 'sets @session for show and destroy actions' do
      get :show, params: { id: session.id }, format: :json
      expect(assigns(:session)).to eq(session)
    end
  end
end
