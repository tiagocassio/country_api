require 'rails_helper'

RSpec.describe V1::CountriesController, type: :controller do
  let!(:country) { create(:country, name: 'Brazil', slug: 'brazil') }
  let!(:other_country) { create(:country, name: 'Argentina', slug: 'argentina') }

  let(:session_record) { create(:session) }
  let(:token) { session_record.signed_id }

  before do
    request.headers['Authorization'] = "Bearer #{token}"
  end

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index, params: {}, format: :json
      expect(response).to be_successful
    end

    it 'filters countries by term' do
      get :index, params: { term: 'Brazil' }, format: :json
      expect(response).to be_successful
    end

    it 'paginates countries' do
      get :index, params: { page: 1, size: 1 }, format: :json
      expect(assigns(:pagy).page.to_i).to eq(1)
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns the requested country' do
      get :show, params: { id: country.slug }, format: :json
      expect(response).to be_successful
      expect(assigns(:country)).to eq(country)
    end

    it 'raises error for non-existent country' do
      expect {
        get :show, params: { id: 'non-existent' }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
