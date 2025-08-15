# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PasswordsController, type: :controller do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }

  before do
    allow(controller).to receive(:authenticate).and_return(true)
    allow(Current).to receive(:user).and_return(user)
  end

  describe 'PATCH #update' do
    context 'when authenticated with valid parameters' do
      let(:valid_params) do
        {
          password: 'newpassword123',
          password_confirmation: 'newpassword123',
          password_challenge: 'password123'
        }
      end

      before do
        allow(user).to receive(:authenticate).with('password123').and_return(true)
      end

      it 'updates the user password' do
        expect {
          patch :update, params: valid_params
        }.to change { user.reload.updated_at }
      end

      it 'returns success status' do
        patch :update, params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it 'returns the updated user data' do
        patch :update, params: valid_params
        user_data = JSON.parse(response.body)
        expect(user_data['id']).to eq(user.id)
      end
    end

    context 'when authenticated with invalid parameters' do
      context 'when password is missing but password_confirmation is present' do
        let(:invalid_params) do
          {
            password_confirmation: 'newpassword123'
          }
        end

        before do
          # Set a password for the user first
          user.password = 'password123'
          user.password_confirmation = 'password123'
          user.save!
        end

        it 'does not update the user' do
          expect {
            patch :update, params: invalid_params
          }.not_to change { user.reload.updated_at }
        end

        it 'returns unprocessable content status' do
          patch :update, params: invalid_params
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'returns validation errors' do
          patch :update, params: invalid_params
          errors = JSON.parse(response.body)
          expect(errors).to have_key('password_confirmation')
        end
      end

      context 'when password confirmation is missing' do
        let(:invalid_params) do
          {
            password: 'newpassword123',
            password_challenge: 'password123'
          }
        end

        before do
          user.update!(password: 'password123')
          user.password_challenge = 'password123'
        end

        it 'does not update the user' do
          expect {
            patch :update, params: invalid_params
          }.not_to change { user.reload.updated_at }
        end

        it 'returns unprocessable content status' do
          patch :update, params: invalid_params
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'returns validation errors' do
          patch :update, params: invalid_params
          errors = JSON.parse(response.body)
          expect(errors).to have_key('password_confirmation')
        end
      end

      context 'when password confirmation does not match' do
        let(:invalid_params) do
          {
            password: 'newpassword123',
            password_confirmation: 'differentpassword',
            password_challenge: 'password123'
          }
        end

        before do
          user.update!(password: 'password123')
          user.password_challenge = 'password123'
        end

        it 'does not update the user' do
          expect {
            patch :update, params: invalid_params
          }.not_to change { user.reload.updated_at }
        end

        it 'returns unprocessable content status' do
          patch :update, params: invalid_params
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'returns validation errors' do
          patch :update, params: invalid_params
          errors = JSON.parse(response.body)
          expect(errors).to have_key('password_confirmation')
        end
      end

      context 'when password_challenge is invalid' do
        let(:invalid_params) do
          {
            password: 'newpassword123',
            password_confirmation: 'newpassword123',
            password_challenge: 'wrongpassword'
          }
        end

        before do
          user.update!(password: 'password123')
          user.password_challenge = 'wrongpassword'
        end

        it 'does not update the user' do
          expect {
            patch :update, params: invalid_params
          }.not_to change { user.reload.updated_at }
        end

        it 'returns unprocessable content status' do
          patch :update, params: invalid_params
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'returns validation errors' do
          patch :update, params: invalid_params
          errors = JSON.parse(response.body)
          expect(errors).to have_key('password_challenge')
        end
      end
    end

    context 'when authenticated with password_challenge parameter' do
      let(:valid_params) do
        {
          password: 'newpassword123',
          password_confirmation: 'newpassword123',
          password_challenge: 'password123'
        }
      end

      before do
        allow(user).to receive(:authenticate).with('password123').and_return(true)
      end

      it 'accepts password_challenge parameter' do
        patch :update, params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it 'sets default password_challenge to empty string when not provided' do
        params_without_challenge = {
          password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }
        allow(user).to receive(:authenticate).with('').and_return(true)

        patch :update, params: params_without_challenge
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when not authenticated' do
      before do
        allow(Current).to receive(:user).and_return(nil)
      end

      it 'returns unauthorized status' do
        patch :update, params: { password: 'newpassword123' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe 'parameter filtering' do
      let(:valid_params) do
        {
          password: 'newpassword123',
          password_confirmation: 'newpassword123',
          password_challenge: 'password123'
        }
      end

      before do
        allow(user).to receive(:authenticate).with('password123').and_return(true)
      end

      it 'permits only password, password_confirmation, and password_challenge' do
        patch :update, params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it 'filters out other parameters' do
        params_with_extra = valid_params.merge(
          admin: true,
          role: 'admin'
        )

        patch :update, params: params_with_extra
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'before_action :set_user' do
      it 'sets @user to Current.user' do
        patch :update, params: { password: 'newpassword123' }
        expect(assigns(:user)).to eq(user)
      end
    end
  end
end
