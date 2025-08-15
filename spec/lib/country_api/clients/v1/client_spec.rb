# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CountryApi::Clients::V1::Client do
  let(:connection) { double('Faraday::Connection') }
  let(:v1_client) { described_class.new(connection) }

  describe '#initialize' do
    it 'sets the connection' do
      expect(v1_client.connection).to eq(connection)
    end
  end

  describe '#all_countries' do
    it 'calls fetch_resource with Countries resource and correct cache key' do
      expect(v1_client).to receive(:fetch_resource).with(CountryApi::Resources::Countries, 'all_countries')
      v1_client.all_countries
    end
  end

  describe '#of_calling_code' do
    let(:calling_code) { '55' }

    it 'calls fetch_resource with CountryCallingCode resource and correct parameters' do
      expect(v1_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryCallingCode, 'calling_code', calling_code)
      v1_client.of_calling_code(calling_code)
    end

    context 'with different parameter types' do
      it 'handles string parameter' do
        expect(v1_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryCallingCode, 'calling_code', '55')
        v1_client.of_calling_code('55')
      end

      it 'handles integer parameter' do
        expect(v1_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryCallingCode, 'calling_code', 55)
        v1_client.of_calling_code(55)
      end

      it 'handles symbol parameter' do
        expect(v1_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryCallingCode, 'calling_code', :'55')
        v1_client.of_calling_code(:'55')
      end
    end
  end

  describe '#of_capital' do
    let(:capital_name) { 'Brasilia' }

    it 'calls fetch_resource with CountryCapital resource and correct parameters' do
      expect(v1_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryCapital, 'capital_name', capital_name)
      v1_client.of_capital(capital_name)
    end

    context 'with different parameter types' do
      it 'handles string parameter' do
        expect(v1_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryCapital, 'capital_name', 'Brasilia')
        v1_client.of_capital('Brasilia')
      end

      it 'handles integer parameter' do
        expect(v1_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryCapital, 'capital_name', 123)
        v1_client.of_capital(123)
      end

      it 'handles symbol parameter' do
        expect(v1_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryCapital, 'capital_name', :brasilia)
        v1_client.of_capital(:brasilia)
      end
    end
  end

  describe '#of_language' do
    let(:language_code) { 'pt' }

    it 'calls fetch_resource with CountryLanguage resource and correct parameters' do
      expect(v1_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryLanguage, 'language_code', language_code)
      v1_client.of_language(language_code)
    end

    context 'with different parameter types' do
      it 'handles string parameter' do
        expect(v1_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryLanguage, 'language_code', 'pt')
        v1_client.of_language('pt')
      end

      it 'handles integer parameter' do
        expect(v1_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryLanguage, 'language_code', 123)
        v1_client.of_language(123)
      end

      it 'handles symbol parameter' do
        expect(v1_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryLanguage, 'language_code', :pt)
        v1_client.of_language(:pt)
      end
    end
  end

  describe '#of_name' do
    let(:country_name) { 'Brazil' }

    it 'calls fetch_resource with CountryName resource and correct parameters' do
      expect(v1_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryName, 'name', country_name)
      v1_client.of_name(country_name)
    end

    context 'with different parameter types' do
      it 'handles string parameter' do
        expect(v1_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryName, 'name', 'Brazil')
        v1_client.of_name('Brazil')
      end

      it 'handles integer parameter' do
        expect(v1_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryName, 'name', 123)
        v1_client.of_name(123)
      end

      it 'handles symbol parameter' do
        expect(v1_client).to receive(:fetch_resource).with(CountryApi::Resources::CountryName, 'name', :brazil)
        v1_client.of_name(:brazil)
      end
    end
  end

  describe 'inheritance' do
    it 'inherits from CountryApi::Clients::Base' do
      expect(described_class.superclass).to eq(CountryApi::Clients::Base)
    end
  end

  describe 'method availability' do
    it 'responds to all_countries' do
      expect(v1_client).to respond_to(:all_countries)
    end

    it 'responds to of_calling_code' do
      expect(v1_client).to respond_to(:of_calling_code)
    end

    it 'responds to of_capital' do
      expect(v1_client).to respond_to(:of_capital)
    end

    it 'responds to of_language' do
      expect(v1_client).to respond_to(:of_language)
    end

    it 'responds to of_name' do
      expect(v1_client).to respond_to(:of_name)
    end
  end
end
