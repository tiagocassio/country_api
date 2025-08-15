# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CountryApi::Resources::Countries do
  let(:connection) { double('Faraday::Connection') }
  let(:countries_resource) { described_class.new(connection) }

  describe '#initialize' do
    it 'sets the connection' do
      expect(countries_resource.instance_variable_get(:@connection)).to eq(connection)
    end
  end

  describe 'constants' do
    it 'defines the correct RESOURCE_NAME' do
      expect(described_class::RESOURCE_NAME).to eq('/api/all')
    end
  end

  describe '#fetch' do
    context 'when called with no parameter' do
      it 'calls GET on the connection with the resource name' do
        expect(connection).to receive(:get).with('/api/all')
        countries_resource.fetch
      end

      it 'calls GET on the connection with nil parameter' do
        expect(connection).to receive(:get).with('/api/all')
        countries_resource.fetch(nil)
      end
    end

    context 'when called with a parameter' do
      it 'ignores the parameter and calls GET with the resource name' do
        expect(connection).to receive(:get).with('/api/all')
        countries_resource.fetch('some_param')
      end

      it 'ignores different parameter types' do
        expect(connection).to receive(:get).with('/api/all')
        countries_resource.fetch(123)
      end
    end

    context 'when called with empty string' do
      it 'calls GET with the resource name' do
        expect(connection).to receive(:get).with('/api/all')
        countries_resource.fetch('')
      end
    end
  end

  describe 'inheritance' do
    it 'inherits from CountryApi::Resources::Base' do
      expect(described_class.superclass).to eq(CountryApi::Resources::Base)
    end
  end
end
