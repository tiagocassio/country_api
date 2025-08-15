# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  describe 'POST #create' do
    let(:valid_params) do
      {
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      }
    end

    let(:invalid_params) do
      {
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'different_password'
      }
    end

    context 'with valid parameters' do
      it 'creates a new user' do
        expect {
          post :create, params: valid_params
        }.to change(User, :count).by(1)
      end

      it 'sets the user email' do
        post :create, params: valid_params
        expect(User.last.email).to eq('test@example.com')
      end

      it 'returns created status' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end

      it 'returns the user data' do
        post :create, params: valid_params
        user_data = JSON.parse(response.body)
        expect(user_data['email']).to eq('test@example.com')
      end

      it 'sends email verification' do
        expect(UserMailer).to receive(:with).with(user: instance_of(User)).and_return(
          double('mailer', email_verification: double('mail', deliver_later: true))
        )
        post :create, params: valid_params
      end
    end

    context 'with invalid parameters' do
      context 'when password confirmation does not match' do
        it 'does not create a user' do
          expect {
            post :create, params: invalid_params
          }.not_to change(User, :count)
        end

        it 'returns unprocessable entity status' do
          post :create, params: invalid_params
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'returns validation errors' do
          post :create, params: invalid_params
          errors = JSON.parse(response.body)
          expect(errors).to have_key('password_confirmation')
        end
      end

      context 'when email is missing' do
        it 'does not create a user' do
          expect {
            post :create, params: { password: 'password123', password_confirmation: 'password123' }
          }.not_to change(User, :count)
        end

              it 'returns unprocessable entity status' do
        post :create, params: { password: 'password123', password_confirmation: 'password123' }
        expect(response).to have_http_status(:unprocessable_content)
      end

        it 'returns validation errors' do
          post :create, params: { password: 'password123', password_confirmation: 'password123' }
          errors = JSON.parse(response.body)
          expect(errors).to have_key('email')
        end
      end

      context 'when password is missing' do
        it 'does not create a user' do
          expect {
            post :create, params: { email: 'test@example.com', password_confirmation: 'password123' }
          }.not_to change(User, :count)
        end

        it 'returns unprocessable entity status' do
          post :create, params: { email: 'test@example.com', password_confirmation: 'password123' }
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'returns validation errors' do
          post :create, params: { email: 'test@example.com', password_confirmation: 'password123' }
          errors = JSON.parse(response.body)
          expect(errors).to have_key('password')
        end
      end

      context 'when email is invalid format' do
        it 'does not create a user' do
          expect {
            post :create, params: { email: 'invalid-email', password: 'password123', password_confirmation: 'password123' }
          }.not_to change(User, :count)
        end

        it 'returns unprocessable entity status' do
          post :create, params: { email: 'invalid-email', password: 'password123', password_confirmation: 'password123' }
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'returns validation errors' do
          post :create, params: { email: 'invalid-email', password: 'password123', password_confirmation: 'password123' }
          errors = JSON.parse(response.body)
          expect(errors).to have_key('email')
        end
      end

      context 'when password is too short' do
        it 'does not create a user' do
          expect {
            post :create, params: { email: 'test@example.com', password: '123', password_confirmation: '123' }
          }.not_to change(User, :count)
        end

        it 'returns unprocessable entity status' do
          post :create, params: { email: 'test@example.com', password: '123', password_confirmation: '123' }
          expect(response).to have_http_status(:unprocessable_content)
        end

        it 'returns validation errors' do
          post :create, params: { email: 'test@example.com', password: '123', password_confirmation: '123' }
          errors = JSON.parse(response.body)
          expect(errors).to have_key('password')
        end
      end
    end

    context 'when email already exists' do
      before do
        create(:user, email: 'test@example.com')
      end

      it 'does not create a duplicate user' do
        expect {
          post :create, params: valid_params
        }.not_to change(User, :count)
      end

      it 'returns unprocessable entity status' do
        post :create, params: valid_params
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'returns validation errors' do
        post :create, params: valid_params
        errors = JSON.parse(response.body)
        expect(errors).to have_key('email')
      end
    end

    describe 'authentication' do
      it 'skips authentication for create action' do
        expect(controller.class._process_action_callbacks.map(&:filter)).not_to include(:authenticate)
      end
    end

    describe 'parameter filtering' do
      it 'permits only email, password, and password_confirmation' do
        post :create, params: {
          email: 'test@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          admin: true,
          extra_param: 'value'
        }

        user = User.last
        expect(user.email).to eq('test@example.com')
        expect(user).not_to respond_to(:admin)
        expect(user).not_to respond_to(:extra_param)
      end
    end
  end
end
