require 'swagger_helper'

RSpec.describe 'Authentication API', swagger_doc: 'v1/swagger.json', type: :request do
  path '/sign_in' do
    post 'Signs in a user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'user@example.com' },
          password: { type: :string, example: 'password123' }
        },
        required: %w[email password]
      }

      response '200', 'user signed in' do
        schema type: :object, properties: {
          token: { type: :string, example: 'eyJhbGciOiJIUzI1NiJ9...' }
        }

        let(:user) { create(:user, email: 'user@example.com', password: 'password123') }
        let(:credentials) { { email: user.email, password: 'password123' } }

        run_test!
      end

      response '401', 'invalid credentials' do
        schema '$ref' => '#/components/schemas/Error'
        let(:credentials) { { email: 'invalid@example.com', password: 'wrongpassword' } }
        run_test!
      end
    end
  end

  path '/sign_up' do
    post 'Signs up a new user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user_data, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'newuser@example.com' },
          password: { type: :string, example: 'password123' },
          password_confirmation: { type: :string, example: 'password123' }
        },
        required: [ 'email', 'password', 'password_confirmation' ]
      }

      response '201', 'user created' do
        schema type: :object, properties: {
          message: { type: :string, example: 'User created successfully' }
        }

        let(:user_data) { { email: 'newuser@example.com', password: 'password123', password_confirmation: 'password123' } }
        run_test!
      end

      response '422', 'validation error' do
        schema '$ref' => '#/components/schemas/Error'
        let(:user_data) { { email: 'invalid-email', password: 'short', password_confirmation: 'different' } }
        run_test!
      end
    end
  end
end
