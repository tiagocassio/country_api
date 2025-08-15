# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CountryApi::Resources::CountryName do
  let(:connection) { double('Faraday::Connection') }
  let(:country_name_resource) { described_class.new(connection) }

  describe '#initialize' do
    it 'sets the connection' do
      expect(country_name_resource.instance_variable_get(:@connection)).to eq(connection)
    end
  end

  describe 'constants' do
    it 'defines the correct RESOURCE_NAME' do
      expect(described_class::RESOURCE_NAME).to eq('/api/name')
    end
  end

  describe '#fetch' do
    context 'when called with a string parameter' do
      it 'calls GET on the connection with the correct URL' do
        expect(connection).to receive(:get).with('/api/name/brazil')
        country_name_resource.fetch('Brazil')
      end

      it 'downcases the parameter' do
        expect(connection).to receive(:get).with('/api/name/brazil')
        country_name_resource.fetch('BRAZIL')
      end

      it 'strips whitespace from the parameter' do
        expect(connection).to receive(:get).with('/api/name/brazil')
        country_name_resource.fetch('  Brazil  ')
      end
    end

    context 'when called with different parameter types' do
      it 'converts integer to string' do
        expect(connection).to receive(:get).with('/api/name/123')
        country_name_resource.fetch(123)
      end

      it 'converts symbol to string' do
        expect(connection).to receive(:get).with('/api/name/brazil')
        country_name_resource.fetch(:brazil)
      end

      it 'handles nil parameter' do
        expect(connection).to receive(:get).with('/api/name/')
        country_name_resource.fetch(nil)
      end
    end

    context 'when called with edge cases' do
      it 'handles empty string' do
        expect(connection).to receive(:get).with('/api/name/')
        country_name_resource.fetch('')
      end

      it 'handles string with only whitespace' do
        expect(connection).to receive(:get).with('/api/name/')
        country_name_resource.fetch('   ')
      end

      it 'handles special characters' do
        expect(connection).to receive(:get).with('/api/name/usa!@#')
        country_name_resource.fetch('USA!@#')
      end
    end
  end

  describe 'inheritance' do
    it 'inherits from CountryApi::Resources::Base' do
      expect(described_class.superclass).to eq(CountryApi::Resources::Base)
    end
  end
end
