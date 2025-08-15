# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CountryApi::Resources::CountryCallingCode do
  let(:connection) { double('Faraday::Connection') }
  let(:country_calling_code_resource) { described_class.new(connection) }

  describe '#initialize' do
    it 'sets the connection' do
      expect(country_calling_code_resource.instance_variable_get(:@connection)).to eq(connection)
    end
  end

  describe 'constants' do
    it 'defines the correct RESOURCE_NAME' do
      expect(described_class::RESOURCE_NAME).to eq('/api/callingcode')
    end
  end

  describe '#fetch' do
    context 'when called with a string parameter' do
      it 'calls GET on the connection with the correct URL' do
        expect(connection).to receive(:get).with('/api/callingcode/55')
        country_calling_code_resource.fetch('55')
      end

      it 'downcases the parameter' do
        expect(connection).to receive(:get).with('/api/callingcode/55')
        country_calling_code_resource.fetch('55')
      end

      it 'strips whitespace from the parameter' do
        expect(connection).to receive(:get).with('/api/callingcode/55')
        country_calling_code_resource.fetch('  55  ')
      end
    end

    context 'when called with different parameter types' do
      it 'converts integer to string' do
        expect(connection).to receive(:get).with('/api/callingcode/55')
        country_calling_code_resource.fetch(55)
      end

      it 'converts symbol to string' do
        expect(connection).to receive(:get).with('/api/callingcode/55')
        country_calling_code_resource.fetch(:'55')
      end

      it 'handles nil parameter' do
        expect(connection).to receive(:get).with('/api/callingcode/')
        country_calling_code_resource.fetch(nil)
      end
    end

    context 'when called with edge cases' do
      it 'handles empty string' do
        expect(connection).to receive(:get).with('/api/callingcode/')
        country_calling_code_resource.fetch('')
      end

      it 'handles string with only whitespace' do
        expect(connection).to receive(:get).with('/api/callingcode/')
        country_calling_code_resource.fetch('   ')
      end

      it 'handles special characters' do
        expect(connection).to receive(:get).with('/api/callingcode/123!@#')
        country_calling_code_resource.fetch('123!@#')
      end
    end
  end

  describe 'inheritance' do
    it 'inherits from CountryApi::Resources::Base' do
      expect(described_class.superclass).to eq(CountryApi::Resources::Base)
    end
  end
end
