# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CountryApi::Clients::Base do
  let(:connection) { double('Faraday::Connection') }
  let(:base_client) { described_class.new(connection) }

  describe '#initialize' do
    it 'sets the connection' do
      expect(base_client.connection).to eq(connection)
    end
  end

  describe '#connection=' do
    it 'allows setting the connection' do
      new_connection = double('NewConnection')
      base_client.connection = new_connection
      expect(base_client.connection).to eq(new_connection)
    end
  end

  describe 'abstract methods' do
    it 'raises NotImplementedError for #fetch' do
      expect { base_client.fetch }.to raise_error(NotImplementedError)
    end

    it 'raises NotImplementedError for #get' do
      expect { base_client.get(1) }.to raise_error(NotImplementedError)
    end

    it 'raises NotImplementedError for #post' do
      expect { base_client.post('body') }.to raise_error(NotImplementedError)
    end

    it 'raises NotImplementedError for #put' do
      expect { base_client.put(1, 'body') }.to raise_error(NotImplementedError)
    end

    it 'raises NotImplementedError for #patch' do
      expect { base_client.patch(1, 'body') }.to raise_error(NotImplementedError)
    end

    it 'raises NotImplementedError for #delete' do
      expect { base_client.delete(1) }.to raise_error(NotImplementedError)
    end
  end

  describe '#fetch_resource' do
    let(:resource_class) { double('ResourceClass') }
    let(:resource_instance) { double('ResourceInstance') }
    let(:response) { double('Response', body: { 'data' => 'test' }, url: 'https://example.com') }
    let(:cache_key) { 'test_cache_key' }
    let(:param) { 'test_param' }

    before do
      allow(resource_class).to receive(:new).with(connection).and_return(resource_instance)
      allow(resource_instance).to receive(:fetch).with(any_args).and_return(response)
      allow(Rails.cache).to receive(:fetch).and_yield
      allow(Rails.logger).to receive(:error)
    end

    it 'creates a resource instance with the connection' do
      expect(resource_class).to receive(:new).with(connection)
      base_client.send(:fetch_resource, resource_class, cache_key, param)
    end

    it 'calls fetch on the resource instance with the param' do
      expect(resource_instance).to receive(:fetch).with(param)
      base_client.send(:fetch_resource, resource_class, cache_key, param)
    end

    it 'returns the response body' do
      result = base_client.send(:fetch_resource, resource_class, cache_key, param)
      expect(result).to eq({ 'data' => 'test' })
    end

    it 'caches the result with the correct key' do
      expected_cache_key = "country_api_#{cache_key}_#{param}"
      expect(Rails.cache).to receive(:fetch).with(expected_cache_key, expires_in: 5.minutes)
      base_client.send(:fetch_resource, resource_class, cache_key, param)
    end

    it 'caches the result without param when param is nil' do
      expected_cache_key = "country_api_#{cache_key}"
      expect(Rails.cache).to receive(:fetch).with(expected_cache_key, expires_in: 5.minutes)
      base_client.send(:fetch_resource, resource_class, cache_key, nil)
    end

    it 'caches the result without param when param is empty string' do
      expected_cache_key = "country_api_#{cache_key}_"
      expect(Rails.cache).to receive(:fetch).with(expected_cache_key, expires_in: 5.minutes)
      base_client.send(:fetch_resource, resource_class, cache_key, '')
    end

    context 'when Faraday::Error occurs' do
      let(:faraday_error) { Faraday::Error.new('Connection failed') }

      before do
        allow(resource_instance).to receive(:fetch).and_raise(faraday_error)
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error).with("Failed to fetch data from API: #{faraday_error.message}")
        base_client.send(:fetch_resource, resource_class, cache_key, param)
      end

      it 'returns nil' do
        result = base_client.send(:fetch_resource, resource_class, cache_key, param)
        expect(result).to be_nil
      end
    end

    context 'when param is an integer' do
      let(:param) { 123 }

      it 'converts the param to string for cache key' do
        expected_cache_key = "country_api_#{cache_key}_#{param}"
        expect(Rails.cache).to receive(:fetch).with(expected_cache_key, expires_in: 5.minutes)
        base_client.send(:fetch_resource, resource_class, cache_key, param)
      end
    end

    context 'when param has whitespace' do
      let(:param) { '  test  ' }

      it 'trims whitespace for cache key' do
        expected_cache_key = "country_api_#{cache_key}_#{param}"
        expect(Rails.cache).to receive(:fetch).with(expected_cache_key, expires_in: 5.minutes)
        base_client.send(:fetch_resource, resource_class, cache_key, param)
      end
    end
  end
end
