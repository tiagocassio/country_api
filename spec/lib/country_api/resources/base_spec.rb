# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CountryApi::Resources::Base do
  let(:connection) { double('Faraday::Connection') }
  let(:base_resource) { described_class.new(connection) }

  describe '#initialize' do
    it 'sets the connection' do
      expect(base_resource.instance_variable_get(:@connection)).to eq(connection)
    end
  end

  describe '#fetch' do
    it 'raises NotImplementedError' do
      expect { base_resource.fetch('param') }.to raise_error(NotImplementedError)
    end
  end

  describe 'connection access' do
    it 'has access to the connection instance variable' do
      expect(base_resource.instance_variable_get(:@connection)).to eq(connection)
    end
  end
end
