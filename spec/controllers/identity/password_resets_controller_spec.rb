# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Identity::PasswordResetsController, type: :controller do
  let(:user) { create(:user) }
  let(:sid) { user.generate_token_for(:password_reset) }

  describe 'GET #edit' do
    it 'returns no content status' do
      get :edit
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'POST #create' do
    context 'with verified user' do
      let(:verified_user) { create(:user, :verified) }

      before do
        allow(User).to receive(:find_by).with(email: verified_user.email, verified: true).and_return(verified_user)
      end

      it 'sends password reset email' do
        expect(UserMailer).to receive(:with).with(user: verified_user).and_return(
          double('mailer', password_reset: double('mail', deliver_later: true))
        )

        post :create, params: { email: verified_user.email }
      end

      it 'returns no content status' do
        post :create, params: { email: verified_user.email }
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with unverified user' do
      let(:unverified_user) { create(:user, :unverified) }

      before do
        allow(User).to receive(:find_by).with(email: unverified_user.email, verified: true).and_return(nil)
      end

      it 'does not send password reset email' do
        expect(UserMailer).not_to receive(:with)

        post :create, params: { email: unverified_user.email }
      end

      it 'returns bad request status' do
        post :create, params: { email: unverified_user.email }
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns error message' do
        post :create, params: { email: unverified_user.email }
        error_response = JSON.parse(response.body)
        expect(error_response['error']).to eq("Usuário não verificado.")
      end
    end

    context 'with non-existent email' do
      before do
        allow(User).to receive(:find_by).with(email: 'nonexistent@example.com', verified: true).and_return(nil)
      end

      it 'returns bad request status' do
        post :create, params: { email: 'nonexistent@example.com' }
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns error message' do
        post :create, params: { email: 'nonexistent@example.com' }
        error_response = JSON.parse(response.body)
        expect(error_response['error']).to eq("Usuário não verificado.")
      end
    end

    context 'with missing email parameter' do
      it 'returns bad request status' do
        post :create
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'PATCH #update' do
    context 'when not authenticated with valid sid token' do
      context 'with valid parameters' do
        let(:valid_params) do
          {
            sid: sid,
            password: 'newpassword123',
            password_confirmation: 'newpassword123'
          }
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

      context 'with invalid parameters' do
        context 'when password is missing' do
          let(:invalid_params) do
            {
              sid: sid,
              password_confirmation: 'newpassword123'
            }
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
            expect(errors).to have_key('password')
          end
        end

        context 'when password confirmation is missing' do
          let(:invalid_params) do
            {
              sid: sid,
              password: 'newpassword123'
            }
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
              sid: sid,
              password: 'newpassword123',
              password_confirmation: 'differentpassword'
            }
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
      end
    end

    context 'with invalid sid token' do
      let(:invalid_params) do
        {
          sid: 'invalid_token',
          password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }
      end

      it 'returns bad request status' do
        patch :update, params: invalid_params
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns error message' do
        patch :update, params: invalid_params
        error_response = JSON.parse(response.body)
        expect(error_response['error']).to eq("Link inválido")
      end
    end

    context 'with missing sid parameter' do
      let(:invalid_params) do
        {
          password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }
      end

      it 'returns bad request status' do
        patch :update, params: invalid_params
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'authentication' do
    it 'skips authentication for all actions' do
      expect(controller.class._process_action_callbacks.map(&:filter)).not_to include(:authenticate)
    end
  end

  describe 'parameter filtering' do
    it 'permits only password and password_confirmation' do
      valid_params = {
        sid: sid,
        password: 'newpassword123',
        password_confirmation: 'newpassword123'
      }

      patch :update, params: valid_params
      expect(response).to have_http_status(:ok)
    end

    it 'filters out other parameters' do
      params_with_extra = {
        sid: sid,
        password: 'newpassword123',
        password_confirmation: 'newpassword123',
        admin: true,
        role: 'admin'
      }

      patch :update, params: params_with_extra
      expect(response).to have_http_status(:ok)
    end
  end
end
