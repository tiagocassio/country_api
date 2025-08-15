# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CountryApi::Clients::V2::Client do
  let(:connection) { double('Faraday::Connection') }
  let(:v2_client) { described_class.new(connection) }

  describe '#initialize' do
    it 'sets the connection' do
      expect(v2_client.connection).to eq(connection)
    end
  end

  describe '#of_currency' do
    let(:currency_code) { 'BRL' }

    it 'calls fetch_resource with CountryCurrency resource and correct parameters' do
      expect(v2_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryCurrency, 'currency_code', currency_code)
      v2_client.of_currency(currency_code)
    end

    context 'with different parameter types' do
      it 'handles string parameter' do
        expect(v2_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryCurrency, 'currency_code', 'BRL')
        v2_client.of_currency('BRL')
      end

      it 'handles integer parameter' do
        expect(v2_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryCurrency, 'currency_code', 123)
        v2_client.of_currency(123)
      end

      it 'handles symbol parameter' do
        expect(v2_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryCurrency, 'currency_code', :brl)
        v2_client.of_currency(:brl)
      end
    end
  end

  describe '#of_region' do
    let(:region_code) { 'Americas' }

    it 'calls fetch_resource with CountryRegion resource and correct parameters' do
      expect(v2_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryRegion, 'region_code', region_code)
      v2_client.of_region(region_code)
    end

    context 'with different parameter types' do
      it 'handles string parameter' do
        expect(v2_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryRegion, 'region_code', 'Americas')
        v2_client.of_region('Americas')
      end

      it 'handles integer parameter' do
        expect(v2_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryRegion, 'region_code', 123)
        v2_client.of_region(123)
      end

      it 'handles symbol parameter' do
        expect(v2_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryRegion, 'region_code', :americas)
        v2_client.of_region(:americas)
      end
    end
  end

  describe 'inheritance' do
    it 'inherits from CountryApi::Clients::Base' do
      expect(described_class.superclass).to eq(CountryApi::Clients::Base)
    end
  end

  describe 'method availability' do
    it 'responds to of_currency' do
      expect(v2_client).to respond_to(:of_currency)
    end

    it 'responds to of_region' do
      expect(v2_client).to respond_to(:of_region)
    end
  end

  describe 'method count' do
    it 'has exactly 2 public methods' do
      public_methods = described_class.instance_methods(false)
      expect(public_methods.count).to eq(2)
    end

    it 'has the expected method names' do
      public_methods = described_class.instance_methods(false)
      expect(public_methods).to include(:of_currency, :of_region)
    end
  end
end
