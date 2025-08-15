# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CountryApi::Resources::CountryCurrency do
  let(:connection) { double('Faraday::Connection') }
  let(:country_currency_resource) { described_class.new(connection) }

  describe '#initialize' do
    it 'sets the connection' do
      expect(country_currency_resource.instance_variable_get(:@connection)).to eq(connection)
    end
  end

  describe 'constants' do
    it 'defines the correct RESOURCE_NAME' do
      expect(described_class::RESOURCE_NAME).to eq('/api/currency')
    end
  end

  describe '#fetch' do
    context 'when called with a string parameter' do
      it 'calls GET on the connection with the correct URL' do
        expect(connection).to receive(:get).with('/api/currency/brl')
        country_currency_resource.fetch('BRL')
      end

      it 'downcases the parameter' do
        expect(connection).to receive(:get).with('/api/currency/brl')
        country_currency_resource.fetch('BRL')
      end

      it 'strips whitespace from the parameter' do
        expect(connection).to receive(:get).with('/api/currency/brl')
        country_currency_resource.fetch('  BRL  ')
      end
    end

    context 'when called with different parameter types' do
      it 'converts integer to string' do
        expect(connection).to receive(:get).with('/api/currency/123')
        country_currency_resource.fetch(123)
      end

      it 'converts symbol to string' do
        expect(connection).to receive(:get).with('/api/currency/brl')
        country_currency_resource.fetch(:brl)
      end

      it 'handles nil parameter' do
        expect(connection).to receive(:get).with('/api/currency/')
        country_currency_resource.fetch(nil)
      end
    end
  end

  describe 'inheritance' do
    it 'inherits from CountryApi::Resources::Base' do
      expect(described_class.superclass).to eq(CountryApi::Resources::Base)
    end
  end
end
