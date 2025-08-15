# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CountryApi::Client do
  let(:api_key) { 'test_api_key_123' }
  let(:client) { described_class.new }

  before do
    allow(Rails.application.credentials).to receive(:country_api).and_return({ api_key: api_key })
  end

  describe '#initialize' do
    it 'sets the api_key from Rails credentials' do
      expect(client.instance_variable_get(:@api_key)).to eq(api_key)
    end
  end

  describe '#v1' do
    it 'returns a V1 client instance' do
      v1_client = client.v1
      expect(v1_client).to be_a(CountryApi::Clients::V1::Client)
    end

    it 'passes the connection to the V1 client' do
      connection = client.send(:connection)
      expect(CountryApi::Clients::V1::Client).to receive(:new).with(connection)
      client.v1
    end
  end

  describe '#v2' do
    it 'returns a V2 client instance' do
      v2_client = client.v2
      expect(v2_client).to be_a(CountryApi::Clients::V2::Client)
    end

    it 'passes the connection to the V2 client' do
      connection = client.send(:connection)
      expect(CountryApi::Clients::V2::Client).to receive(:new).with(connection)
      client.v2
    end
  end

  describe '#connection' do
    let(:connection) { client.send(:connection) }

    it 'creates a Faraday connection with the correct base URL' do
      expect(connection.url_prefix.to_s).to eq('https://countryapi.io/')
    end

    it 'sets the API key as a parameter' do
      expect(connection.params['apikey']).to eq(api_key)
    end

    it 'configures the connection with the correct middleware' do
      expect(connection.params['apikey']).to eq(api_key)
      expect(connection.url_prefix.to_s).to eq('https://countryapi.io/')
      expect(connection.options.timeout).to eq(5)
    end

    it 'sets the timeout to 5 seconds' do
      expect(connection.options.timeout).to eq(5)
    end

    it 'memoizes the connection' do
      first_connection = client.send(:connection)
      second_connection = client.send(:connection)
      expect(first_connection).to be(first_connection)
    end
  end

  describe 'connection middleware configuration' do
    let(:connection) { client.send(:connection) }

    it 'has the expected number of middleware handlers' do
      expect(connection.builder.handlers.length).to be >= 3
    end

    it 'configures the connection with proper request and response handling' do
      expect(connection).to respond_to(:get)
      expect(connection).to respond_to(:post)
    end

    it 'sets the correct timeout' do
      expect(connection.options.timeout).to eq(5)
    end

    it 'includes the API key in parameters' do
      expect(connection.params['apikey']).to eq(api_key)
    end
  end

  describe 'constants' do
    it 'defines the correct BASE_URL' do
      expect(described_class::BASE_URL).to eq('https://countryapi.io')
    end
  end

  context 'when Rails credentials are not configured' do
    before do
      allow(Rails.application.credentials).to receive(:country_api).and_return(nil)
    end

    it 'raises an error when trying to access the api_key' do
      expect { described_class.new }.to raise_error(NoMethodError)
    end
  end

  context 'when Rails credentials are configured differently' do
    before do
      allow(Rails.application.credentials).to receive(:country_api).and_return({ api_key: 'different_key' })
    end

    it 'uses the configured api_key' do
      client = described_class.new
      expect(client.instance_variable_get(:@api_key)).to eq('different_key')
    end
  end
end
