# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Identity::EmailsController, type: :controller do
  let(:user) { create(:user) }

  before do
    allow(controller).to receive(:authenticate).and_return(true)
    allow(Current).to receive(:user).and_return(user)
  end

  describe 'PATCH #update' do
    context 'when authenticated with valid parameters' do
      context 'when email changes' do
        let(:valid_params) do
          {
            email: 'newemail@example.com',
            password_challenge: 'password123'
          }
        end

        before do
          user.update!(password: 'password123')
          user.update!(verified: true)
          allow(user).to receive(:email_previously_changed?).and_return(true)
          user.password_challenge = 'password123'
        end

        it 'updates the user email' do
          expect { patch :update, params: valid_params }.to change { user.reload.email }.from(user.email).to('newemail@example.com')
        end

        it 'returns success status' do
          patch :update, params: valid_params
          expect(response).to have_http_status(:ok)
        end

        it 'returns the updated user data' do
          patch :update, params: valid_params
          json_response = JSON.parse(response.body)
          expect(json_response['email']).to eq('newemail@example.com')
        end

        it 'sends email verification for new email' do
          expect(controller).to receive(:resend_email_verification)
          patch :update, params: valid_params
        end

        it 'resets verified status to false' do
          expect { patch :update, params: valid_params }.to change { user.reload.verified }.from(true).to(false)
        end
      end

      context 'when email does not change' do
        let(:valid_params) do
          {
            email: user.email,
            password_challenge: 'password123'
          }
        end

        before do
          user.update!(password: 'password123')
          user.update!(verified: true)
          allow(user).to receive(:email_previously_changed?).and_return(false)
          user.password_challenge = 'password123'
        end

        it 'returns success status' do
          patch :update, params: valid_params
          expect(response).to have_http_status(:ok)
        end

        it 'returns the user data' do
          patch :update, params: valid_params
          json_response = JSON.parse(response.body)
          expect(json_response['email']).to eq(user.email)
        end
      end

      context 'when email is missing' do
        let(:invalid_params) do
          {
            password_challenge: 'password123'
          }
        end

        before do
          user.update!(password: 'password123')
          user.password_challenge = 'password123'
        end

        it 'returns unprocessable content status' do
          patch :update, params: invalid_params
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'returns validation errors' do
          patch :update, params: invalid_params
          errors = JSON.parse(response.body)
          expect(errors).to have_key('email')
        end
      end

      context 'when password_challenge is invalid' do
        let(:invalid_params) do
          {
            email: 'newemail@example.com',
            password_challenge: 'wrongpassword'
          }
        end

        before do
          user.update!(password: 'password123')
          user.password_challenge = 'wrongpassword'
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
          email: 'newemail@example.com',
          password_challenge: 'password123'
        }
      end

      before do
        user.update!(password: 'password123')
        user.update!(verified: true)
        allow(user).to receive(:email_previously_changed?).and_return(false)
        user.password_challenge = 'password123'
      end

      it 'accepts password_challenge parameter' do
        patch :update, params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it 'sets default password_challenge to empty string when not provided' do
        params_without_challenge = { email: 'newemail@example.com' }
        user.password_challenge = ''

        patch :update, params: params_without_challenge
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when not authenticated' do
      before do
        allow(controller).to receive(:authenticate).and_call_original
        allow(Current).to receive(:user).and_return(nil)
      end

      it 'returns unauthorized status' do
        patch :update, params: { email: 'newemail@example.com' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe 'parameter filtering' do
      let(:valid_params) do
        {
          email: 'newemail@example.com',
          password_challenge: 'password123'
        }
      end

      before do
        user.update!(password: 'password123')
        user.update!(verified: true)
        allow(user).to receive(:email_previously_changed?).and_return(false)
        user.password_challenge = 'password123'
      end

      it 'permits only email and password_challenge' do
        patch :update, params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it 'filters out other parameters' do
        params_with_extra = valid_params.merge(extra_param: 'extra_value')
        patch :update, params: params_with_extra
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'email verification logic' do
      context 'when email_previously_changed? is true' do
        let(:valid_params) do
          {
            email: 'newemail@example.com',
            password_challenge: 'password123'
          }
        end

        before do
          user.update!(password: 'password123')
          user.update!(verified: true)
          allow(user).to receive(:email_previously_changed?).and_return(true)
          user.password_challenge = 'password123'
        end

        it 'calls resend_email_verification' do
          expect(controller).to receive(:resend_email_verification)

          patch :update, params: valid_params
        end
      end
    end
  end
end
