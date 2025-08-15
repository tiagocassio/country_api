require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s
  config.swagger_docs = {
    'v1/swagger.json' => {
      openapi: '3.0.1',
      info: {
        title: 'Country API V1',
        version: 'v1',
        description: 'API for managing and retrieving country information',
        contact: {
          name: 'API Support',
          email: 'support@example.com'
        }
      },
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          }
        },
        schemas: {
          Country: {
            type: :object,
            properties: {
              id: { type: :string, example: 'brazil' },
              name: { type: :string, example: 'Brazil' },
              official_name: { type: :string, example: 'Federative Republic of Brazil' },
              capital: { type: :string, example: 'Brasília' },
              region: { type: :string, example: 'Americas' },
              subregion: { type: :string, example: 'South America' },
              population: { type: :integer, example: 212559417 },
              area: { type: :number, example: 8515767.0 },
              calling_code: { type: :string, example: '55' },
              currency: { type: :string, example: 'BRL' },
              languages: { type: :array, items: { type: :string }, example: [ 'Portuguese' ] },
              flag_url: { type: :string, example: 'https://flagcdn.com/br.svg' },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          },
          CountryCollection: {
            type: :object,
            properties: {
              data: {
                type: :array,
                items: { '$ref' => '#/components/schemas/Country' }
              },
              pagination: {
                type: :object,
                properties: {
                  count: { type: :integer, example: 20 },
                  page: { type: :integer, example: 1 },
                  items: { type: :integer, example: 20 },
                  pages: { type: :integer, example: 10 }
                }
              }
            }
          },
          Error: {
            type: :object,
            properties: {
              error: { type: :string, example: 'Error message' }
            }
          },
          AuthCredentials: {
            type: :object,
            properties: {
              email: { type: :string, example: 'user@example.com' },
              password: { type: :string, example: 'password123' }
            },
            required: [ 'email', 'password' ]
          },
          UserRegistration: {
            type: :object,
            properties: {
              email: { type: :string, example: 'newuser@example.com' },
              password: { type: :string, example: 'password123' },
              password_confirmation: { type: :string, example: 'password123' }
            },
            required: [ 'email', 'password', 'password_confirmation' ]
          },
          AuthResponse: {
            type: :object,
            properties: {
              token: { type: :string, example: 'eyJhbGciOiJIUzI1NiJ9...' }
            }
          },
          Pagination: {
            type: :object,
            properties: {
              count: { type: :integer, example: 20 },
              page: { type: :integer, example: 1 },
              items: { type: :integer, example: 20 },
              pages: { type: :integer, example: 10 }
            }
          },
          SearchParams: {
            type: :object,
            properties: {
              term: { type: :string, example: 'brazil', description: 'Search term to filter countries' },
              page: { type: :integer, example: 1, description: 'Page number for pagination' },
              items: { type: :integer, example: 20, description: 'Number of items per page' }
            }
          }
        }
      },
      security: [
        {
          bearerAuth: []
        }
      ]
    }
  }
end
