# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CountryApi::Resources::CountryLanguage do
  let(:connection) { double('Faraday::Connection') }
  let(:country_language_resource) { described_class.new(connection) }

  describe '#initialize' do
    it 'sets the connection' do
      expect(country_language_resource.instance_variable_get(:@connection)).to eq(connection)
    end
  end

  describe 'constants' do
    it 'defines the correct RESOURCE_NAME' do
      expect(described_class::RESOURCE_NAME).to eq('/api/language')
    end
  end

  describe '#fetch' do
    context 'when called with a string parameter' do
      it 'calls GET on the connection with the correct URL' do
        expect(connection).to receive(:get).with('/api/language/portuguese')
        country_language_resource.fetch('Portuguese')
      end

      it 'downcases the parameter' do
        expect(connection).to receive(:get).with('/api/language/portuguese')
        country_language_resource.fetch('PORTUGUESE')
      end

      it 'strips whitespace from the parameter' do
        expect(connection).to receive(:get).with('/api/language/portuguese')
        country_language_resource.fetch('  Portuguese  ')
      end
    end

    context 'when called with different parameter types' do
      it 'converts integer to string' do
        expect(connection).to receive(:get).with('/api/language/123')
        country_language_resource.fetch(123)
      end

      it 'converts symbol to string' do
        expect(connection).to receive(:get).with('/api/language/portuguese')
        country_language_resource.fetch(:portuguese)
      end

      it 'handles nil parameter' do
        expect(connection).to receive(:get).with('/api/language/')
        country_language_resource.fetch(nil)
      end
    end
  end

  describe 'inheritance' do
    it 'inherits from CountryApi::Resources::Base' do
      expect(described_class.superclass).to eq(CountryApi::Resources::Base)
    end
  end
end
