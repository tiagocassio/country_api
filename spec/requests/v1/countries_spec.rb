require 'swagger_helper'

RSpec.describe 'Countries API', swagger_doc: 'v1/swagger.json', type: :request do
  path '/v1/countries' do
    get 'Retrieves a list of countries' do
      tags 'Countries'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :term, in: :query, type: :string, required: false, description: 'Search term to filter countries'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number for pagination'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'

      response '200', 'countries found' do
        schema '$ref' => '#/components/schemas/CountryCollection'

        let(:user) { create(:user) }
        let(:session) { create(:session, user: user) }
        let(:Authorization) { "Bearer #{session.signed_id}" }
        let(:countries) { create_list(:country, 3) }

        before do
          countries
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_present
          expect(data['pagination']).to be_present
        end
      end

      response '401', 'unauthorized' do
        schema '$ref' => '#/components/schemas/Error'
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end
  end

  path '/v1/countries/{id}' do
    get 'Retrieves a country' do
      tags 'Countries'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :string, required: true, description: 'Country identifier (slug)'

      response '200', 'country found' do
        schema '$ref' => '#/components/schemas/Country'

        let(:user) { create(:user) }
        let(:session) { create(:session, user: user) }
        let(:Authorization) { "Bearer #{session.signed_id}" }
        let(:country) { create(:country) }
        let(:id) { country.slug }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(country.slug)
          expect(data['name']).to eq(country.name)
        end
      end

      response '401', 'unauthorized' do
        schema '$ref' => '#/components/schemas/Error'
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { 'invalid-slug' }
        run_test!
      end

      response '404', 'country not found' do
        schema '$ref' => '#/components/schemas/Error'

        let(:user) { create(:user) }
        let(:session) { create(:session, user: user) }
        let(:Authorization) { "Bearer #{session.signed_id}" }
        let(:id) { 'non-existent-slug' }
        run_test!
      end
    end
  end
end
