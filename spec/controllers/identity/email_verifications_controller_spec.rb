# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Identity::EmailVerificationsController, type: :controller do
  let(:user) { create(:user, :unverified) }

  describe 'GET #show' do
    context 'when not authenticated' do
      let(:sid) { user.generate_token_for(:email_verification) }

      it 'verifies the user email' do
        expect { get :show, params: { sid: sid } }.to change { user.reload.verified }.from(false).to(true)
      end

      it 'returns no content status' do
        get :show, params: { sid: sid }
        expect(response).to have_http_status(:no_content)
      end

      it 'sets verified to true' do
        get :show, params: { sid: sid }
        user.reload
        expect(user.verified).to be true
      end

      it 'updates the user record' do
        expect { get :show, params: { sid: sid } }.to change { user.reload.updated_at }
      end
    end

    context 'when authenticated' do
      let(:sid) { user.generate_token_for(:email_verification) }

      before do
        allow(controller).to receive(:authenticate).and_return(true)
        allow(Current).to receive(:user).and_return(user)
      end

      it 'still works with valid sid token' do
        expect { get :show, params: { sid: sid } }.to change { user.reload.verified }.from(false).to(true)
      end

      it 'returns no content status' do
        get :show, params: { sid: sid }
        expect(response).to have_http_status(:no_content)
      end

      it 'sets verified to true' do
        get :show, params: { sid: sid }
        user.reload
        expect(user.verified).to be true
      end
    end

    context 'with invalid sid token' do
      let(:invalid_sid) { 'invalid_token' }

      it 'returns bad request status' do
        get :show, params: { sid: invalid_sid }
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns error message' do
        get :show, params: { sid: invalid_sid }
        error_response = JSON.parse(response.body)
        expect(error_response['error']).to eq("That email verification link is invalid")
      end

      it 'does not change user verification status' do
        expect { get :show, params: { sid: invalid_sid } }.not_to change { user.reload.verified }
      end
    end

    context 'with expired sid token' do
      let(:expired_sid) { 'expired_token_that_will_fail_verification' }

      it 'returns bad request status' do
        get :show, params: { sid: expired_sid }
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns error message' do
        get :show, params: { sid: expired_sid }
        error_response = JSON.parse(response.body)
        expect(error_response['error']).to eq("That email verification link is invalid")
      end

      it 'does not change user verification status' do
        expect { get :show, params: { sid: expired_sid } }.not_to change { user.reload.verified }
      end
    end

    context 'with nil sid token' do
      it 'returns bad request status' do
        get :show, params: { sid: nil }
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns error message' do
        get :show, params: { sid: nil }
        error_response = JSON.parse(response.body)
        expect(error_response['error']).to eq("That email verification link is invalid")
      end

      it 'does not change user verification status' do
        expect { get :show, params: { sid: nil } }.not_to change { user.reload.verified }
      end
    end

    context 'with empty sid token' do
      it 'returns bad request status' do
        get :show, params: { sid: '' }
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns error message' do
        get :show, params: { sid: '' }
        error_response = JSON.parse(response.body)
        expect(error_response['error']).to eq("That email verification link is invalid")
      end
    end

    context 'with malformed sid token' do
      let(:malformed_sid) { 'malformed_token_with_special_chars!@#$%^&*()' }

      it 'returns bad request status' do
        get :show, params: { sid: malformed_sid }
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns error message' do
        get :show, params: { sid: malformed_sid }
        error_response = JSON.parse(response.body)
        expect(error_response['error']).to eq("That email verification link is invalid")
      end
    end

    context 'when user is already verified' do
      let(:verified_user) { create(:user, :verified) }
      let(:sid) { verified_user.generate_token_for(:email_verification) }

      it 'still processes the verification request' do
        get :show, params: { sid: sid }
        expect(response).to have_http_status(:no_content)
      end

      it 'keeps verified as true' do
        get :show, params: { sid: sid }
        verified_user.reload
        expect(verified_user.verified).to be true
      end

      it 'returns no content status' do
        get :show, params: { sid: sid }
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with different user token' do
      let(:other_user) { create(:user, :unverified) }
      let(:other_sid) { other_user.generate_token_for(:email_verification) }

      it 'verifies the correct user' do
        expect { get :show, params: { sid: other_sid } }.to change { other_user.reload.verified }.from(false).to(true)
      end

      it 'does not affect the original user' do
        expect { get :show, params: { sid: other_sid } }.not_to change { user.reload.verified }
      end
    end
  end

  describe 'POST #create' do
    context 'when authenticated' do
      before do
        allow(controller).to receive(:authenticate).and_return(true)
        allow(Current).to receive(:user).and_return(user)
      end

      it 'sends email verification email' do
        expect(UserMailer).to receive(:with).with(user: user).and_return(
          double('mailer').tap do |mailer|
            expect(mailer).to receive(:email_verification).and_return(
              double('mail').tap do |mail|
                expect(mail).to receive(:deliver_later)
              end
            )
          end
        )

        post :create
      end

      it 'does not change user verification status' do
        allow(UserMailer).to receive(:with).and_return(
          double('mailer').tap do |mailer|
            allow(mailer).to receive(:email_verification).and_return(
              double('mail').tap do |mail|
                allow(mail).to receive(:deliver_later)
              end
            )
          end
        )

        expect { post :create }.not_to change { user.reload.verified }
      end

      it 'uses the correct mailer method' do
        mailer_double = double('mailer')
        mail_double = double('mail')

        expect(UserMailer).to receive(:with).with(user: user).and_return(mailer_double)
        expect(mailer_double).to receive(:email_verification).and_return(mail_double)
        expect(mail_double).to receive(:deliver_later)

        post :create
      end
    end

    context 'when not authenticated' do
      before do
        allow(controller).to receive(:authenticate).and_return(false)
        allow(Current).to receive(:user).and_return(nil)
      end

      it 'sends email verification email with nil user' do
        expect(UserMailer).to receive(:with).with(user: nil).and_return(
          double('mailer').tap do |mailer|
            expect(mailer).to receive(:email_verification).and_return(
              double('mail').tap do |mail|
                expect(mail).to receive(:deliver_later)
              end
            )
          end
        )

        post :create
      end

      it 'does not change user verification status' do
        allow(UserMailer).to receive(:with).and_return(
          double('mailer').tap do |mailer|
            allow(mailer).to receive(:email_verification).and_return(
              double('mail').tap do |mail|
                allow(mail).to receive(:deliver_later)
              end
            )
          end
        )

        expect { post :create }.not_to change { user.reload.verified }
      end
    end

    context 'with different authenticated user' do
      let(:other_user) { create(:user, :unverified) }

      before do
        allow(controller).to receive(:authenticate).and_return(true)
        allow(Current).to receive(:user).and_return(other_user)
      end

      it 'sends email verification for the authenticated user' do
        expect(UserMailer).to receive(:with).with(user: other_user).and_return(
          double('mailer').tap do |mailer|
            expect(mailer).to receive(:email_verification).and_return(
              double('mail').tap do |mail|
                expect(mail).to receive(:deliver_later)
              end
            )
          end
        )

        post :create
      end
    end
  end

  describe 'authentication' do
    it 'skips authentication for show action' do
      allow(Current).to receive(:user).and_return(nil)

      expect { get :show, params: { sid: 'test_sid' } }.not_to raise_error
    end

    it 'requires authentication for create action' do
      expect(controller.class._process_action_callbacks.map(&:filter)).to include(:authenticate)
    end
  end

  describe 'before_action :set_user' do
    it 'sets @user for show action' do
      sid = user.generate_token_for(:email_verification)
      get :show, params: { sid: sid }
      expect(assigns(:user)).to eq(user)
    end

    it 'handles token parsing errors gracefully' do
      allow(User).to receive(:find_by_token_for!).and_raise(ActiveSupport::MessageVerifier::InvalidSignature)

      get :show, params: { sid: 'invalid_token' }

      expect(response).to have_http_status(:bad_request)
      error_response = JSON.parse(response.body)
      expect(error_response['error']).to eq("That email verification link is invalid")
    end

    it 'handles record not found errors gracefully' do
      allow(User).to receive(:find_by_token_for!).and_raise(ActiveRecord::RecordNotFound)

      get :show, params: { sid: 'nonexistent_token' }

      expect(response).to have_http_status(:bad_request)
      error_response = JSON.parse(response.body)
      expect(error_response['error']).to eq("That email verification link is invalid")
    end

    it 'handles general errors gracefully' do
      allow(User).to receive(:find_by_token_for!).and_raise(StandardError.new("Some unexpected error"))

      get :show, params: { sid: 'error_token' }

      expect(response).to have_http_status(:bad_request)
      error_response = JSON.parse(response.body)
      expect(error_response['error']).to eq("That email verification link is invalid")
    end
  end

  describe 'edge cases' do
    context 'with very long sid token' do
      let(:long_sid) { 'a' * 1000 }

      it 'returns bad request status' do
        get :show, params: { sid: long_sid }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'with sid token containing special characters' do
      let(:special_sid) { "token\nwith\r\ttabs\nand\rnewlines" }

      it 'returns bad request status' do
        get :show, params: { sid: special_sid }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when user is deleted after token generation' do
      let(:sid) { user.generate_token_for(:email_verification) }

      it 'handles gracefully when user is deleted' do
        user.destroy

        get :show, params: { sid: sid }
        expect(response).to have_http_status(:bad_request)
        error_response = JSON.parse(response.body)
        expect(error_response['error']).to eq("That email verification link is invalid")
      end
    end

    context 'with concurrent verification requests' do
      let(:sid) { user.generate_token_for(:email_verification) }

      it 'handles multiple simultaneous requests' do
        threads = []
        results = []

        3.times do
          threads << Thread.new do
            get :show, params: { sid: sid }
            results << response.status
          end
        end

        threads.each(&:join)

        expect(results).to all(eq(204)) # no_content status
        expect(user.reload.verified).to be true
      end
    end
  end
end
