require 'rails_helper'

RSpec.describe Filters::CountryFilter do
  let(:country1) { create(:country, name: 'France', calling_code: '+33', capital: 'Paris', currencies: 'EUR', language: 'French', region: 'Europe') }
  let(:country2) { create(:country, name: 'Germany', calling_code: '+49', capital: 'Berlin', currencies: 'EUR', language: 'German', region: 'Europe') }
  let(:country3) { create(:country, name: 'Brazil', calling_code: '+55', capital: 'Brasilia', currencies: 'BRL', language: 'Portuguese', region: 'South America') }
  let(:countries) { Country.all }
  let(:filter) { described_class.new(countries) }

  describe '#initialize' do
    it 'initializes with default countries' do
      filter = described_class.new
      expect(filter.instance_variable_get(:@countries)).to eq(Country.all)
    end

    it 'initializes with provided countries' do
      expect(filter.instance_variable_get(:@countries)).to eq(countries)
    end
  end

  describe '#filter' do
    it 'chains all filter methods with provided params' do
      params = {
        name: 'France',
        calling_code: '+33',
        capital: 'Paris',
        language: 'French',
        region: 'Europe',
        currency: 'EUR'
      }
      expect(filter).to receive(:by_name).with('France').and_call_original
      expect(filter).to receive(:by_calling_code).with('+33').and_call_original
      expect(filter).to receive(:by_capital_name).with('Paris').and_call_original
      expect(filter).to receive(:by_language).with('French').and_call_original
      expect(filter).to receive(:by_region).with('Europe').and_call_original
      expect(filter).to receive(:by_currency).with('EUR').and_call_original
      filter.filter(params)
    end
  end

  describe '#by_name' do
    it 'filters countries by name' do
      country1
      country2
      filter.by_name('France')
      expect(filter.results).to contain_exactly(country1)
    end

    it 'returns self if name is blank' do
      expect(filter.by_name('')).to eq(filter)
      expect(filter.results).to eq(countries)
    end
  end

  describe '#by_calling_code' do
    it 'filters countries by calling code' do
      country1
      country2
      filter.by_calling_code('+33')
      expect(filter.results).to contain_exactly(country1)
    end

    it 'returns self if calling code is blank' do
      expect(filter.by_calling_code('')).to eq(filter)
      expect(filter.results).to eq(countries)
    end
  end

  describe '#by_capital_name' do
    it 'filters countries by capital name' do
      country1
      country2
      filter.by_capital_name('Paris')
      expect(filter.results).to contain_exactly(country1)
    end

    it 'returns self if capital name is blank' do
      expect(filter.by_capital_name('')).to eq(filter)
      expect(filter.results).to eq(countries)
    end
  end

  describe '#by_currency' do
    it 'filters countries by currency' do
      country1
      country2
      country3
      filter.by_currency('EUR')
      expect(filter.results).to contain_exactly(country1, country2)
    end

    it 'returns self if currency is blank' do
      expect(filter.by_currency('')).to eq(filter)
      expect(filter.results).to eq(countries)
    end
  end

  describe '#by_language' do
    it 'filters countries by language' do
      country1
      country2
      filter.by_language('French')
      expect(filter.results).to contain_exactly(country1)
    end

    it 'returns self if language is blank' do
      expect(filter.by_language('')).to eq(filter)
      expect(filter.results).to eq(countries)
    end
  end

  describe '#by_region' do
    it 'filters countries by region' do
      country1
      country2
      country3
      filter.by_region('Europe')
      expect(filter.results).to contain_exactly(country1, country2)
    end

    it 'returns self if region is blank' do
      expect(filter.by_region('')).to eq(filter)
      expect(filter.results).to eq(countries)
    end
  end

  describe '#results' do
    it 'returns the filtered countries' do
      country1
      filter.by_name('France')
      expect(filter.results).to contain_exactly(country1)
    end
  end
end
