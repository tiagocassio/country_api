require 'rails_helper'

RSpec.describe CountryUpdateService do
  let(:service) { described_class.new }
  let(:mock_client) { instance_double(CountryApi::Client) }
  let(:mock_v1_client) { instance_double(CountryApi::Clients::V1::Client) }

  before do
    allow(CountryApi::Client).to receive(:new).and_return(mock_client)
    allow(mock_client).to receive(:v1).and_return(mock_v1_client)
  end

  describe '.update_all' do
    it 'creates a new instance and calls update_all' do
      expect(described_class).to receive(:new).and_return(service)
      expect(service).to receive(:update_all)
      described_class.update_all
    end
  end

  describe '#update_all' do
    context 'when API call succeeds' do
      let(:countries_data) do
        {
          'US' => {
            'name' => 'United States',
            'alpha2Code' => 'US',
            'alpha3Code' => 'USA',
            'latLng' => { 'country' => [ 38, -97 ] },
            'official_name' => 'United States of America',
            'capital' => 'Washington, D.C.',
            'region' => 'Americas',
            'subregion' => 'North America',
            'population' => 331002651,
            'area' => 9833517,
            'currencies' => { 'USD' => { 'name' => 'US Dollar', 'symbol' => '$' } },
            'languages' => { 'eng' => 'English' },
            'callingCode' => '+1',
            'timezones' => [ 'UTC-12:00', 'UTC-11:00' ],
            'borders' => [ 'CAN', 'MEX' ],
            'flag' => { 'large' => 'https://flagcdn.com/large/us.png' }
          }
        }
      end

      before do
        allow(Rails.logger).to receive(:info)
        allow(mock_v1_client).to receive(:all_countries).and_return(countries_data)
      end

      it 'processes countries successfully' do
        expect(service).to receive(:process_countries).with(countries_data)
        service.update_all
      end

      it 'logs the start message' do
        expect(Rails.logger).to receive(:info).with(I18n.t('country_update.service.starting'))
        service.update_all
      end
    end

    context 'when API call fails' do
      before do
        allow(Rails.logger).to receive(:info)
        allow(Rails.logger).to receive(:error)
        allow(mock_v1_client).to receive(:all_countries).and_return(nil)
      end

      it 'logs error and raises exception' do
        expect(Rails.logger).to receive(:error).with(I18n.t('country_update.service.failed_fetch'))
        expect { service.update_all }.to raise_error(I18n.t('country_update.service.failed_fetch'))
      end
    end
  end

  describe '#process_countries' do
    let(:countries_data) do
      {
        'US' => { 'name' => 'United States', 'alpha2Code' => 'US' },
        'BR' => { 'name' => 'Brazil', 'alpha2Code' => 'BR' }
      }
    end

    before do
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:error)
      allow(Rails.logger).to receive(:warn)
    end

    it 'processes each country and returns stats' do
      allow(service).to receive(:process_single_country)
      allow(service).to receive(:log_results)

      result = service.send(:process_countries, countries_data)

      expect(result).to eq({ created: 0, updated: 0, errors: 0 })
    end

    it 'handles processing errors gracefully' do
      allow(service).to receive(:process_single_country).and_raise(StandardError, 'Test error')
      allow(service).to receive(:log_results)

      result = service.send(:process_countries, countries_data)

      expect(result[:errors]).to eq(2)
      expect(Rails.logger).to have_received(:error).twice
    end

    it 'calls log_results with stats' do
      allow(service).to receive(:process_single_country)
      expect(service).to receive(:log_results).with({ created: 0, updated: 0, errors: 0 })

      service.send(:process_countries, countries_data)
    end
  end

  describe '#process_single_country' do
    let(:country_data) do
      {
        'name' => 'Test Country',
        'alpha2Code' => 'TC',
        'alpha3Code' => 'TST',
        'latLng' => { 'country' => [ 0, 0 ] },
        'official_name' => 'Test Country Official',
        'capital' => 'Test Capital',
        'region' => 'Test Region',
        'subregion' => 'Test Subregion',
        'population' => 1000000,
        'area' => 100000,
        'currencies' => { 'TST' => { 'name' => 'Test Currency', 'symbol' => 'T' } },
        'languages' => { 'tst' => 'Test Language' },
        'callingCode' => '+123',
        'timezones' => [ 'UTC+0' ],
        'borders' => [ 'ABC' ],
        'flag' => { 'large' => 'https://flag.png' }
      }
    end

    let(:stats) { { created: 0, updated: 0, errors: 0 } }
    let(:country) { instance_double(Country, persisted?: true, updated_at: 2.days.ago, name: 'Test Country') }

    before do
      allow(Rails.logger).to receive(:info)
      allow(Country).to receive(:find_or_create_by!).and_return(country)
      allow(country).to receive(:update!)
    end

    context 'when creating a new country' do
      let(:new_country) { instance_double(Country, persisted?: false, new_record?: true, name: 'Test Country') }

      before do
        allow(Country).to receive(:find_or_create_by!).and_return(new_country)
        allow(new_country).to receive(:respond_to?).and_return(true)
        # Mock all the attribute setters that might be called
        allow(new_country).to receive(:name=)
        allow(new_country).to receive(:alpha2_code=)
        allow(new_country).to receive(:alpha3_code=)
        allow(new_country).to receive(:latitude=)
        allow(new_country).to receive(:longitude=)
        allow(new_country).to receive(:official_name=)
        allow(new_country).to receive(:capital=)
        allow(new_country).to receive(:region=)
        allow(new_country).to receive(:subregion=)
        allow(new_country).to receive(:population=)
        allow(new_country).to receive(:area=)
        allow(new_country).to receive(:currencies=)
        allow(new_country).to receive(:language=)
        allow(new_country).to receive(:calling_code=)
        allow(new_country).to receive(:time_zones=)
        allow(new_country).to receive(:borders=)
        allow(new_country).to receive(:flag=)
      end

      it 'increments created count and logs creation' do
        # Mock the find_or_create_by! to execute the block
        allow(Country).to receive(:find_or_create_by!) do |&block|
          block.call(new_country) if block
          new_country
        end

        service.send(:process_single_country, country_data, stats)

        expect(stats[:created]).to eq(1)
        expect(Rails.logger).to have_received(:info).with(I18n.t('country_update.countries.created', name: 'Test Country'))
      end
    end

    context 'when updating an existing country' do
      before do
        allow(country).to receive(:persisted?).and_return(true)
        allow(country).to receive(:updated_at).and_return(2.days.ago)
      end

      it 'updates the country and increments updated count' do
        service.send(:process_single_country, country_data, stats)

        expect(country).to have_received(:update!)
        expect(stats[:updated]).to eq(1)
        expect(Rails.logger).to have_received(:info).with(I18n.t('country_update.countries.updated', name: 'Test Country'))
      end
    end

    context 'when country is recent' do
      before do
        allow(country).to receive(:persisted?).and_return(true)
        allow(country).to receive(:updated_at).and_return(12.hours.ago)
        allow(country).to receive(:new_record?).and_return(false)
      end

      it 'does not update recent countries' do
        service.send(:process_single_country, country_data, stats)

        expect(country).not_to have_received(:update!)
        expect(stats[:updated]).to eq(0)
      end
    end
  end

  describe '#extract_country_attributes' do
    let(:country_data) do
      {
        'name' => 'Test Country',
        'alpha2Code' => 'TC',
        'alpha3Code' => 'TST',
        'latLng' => { 'country' => [ 10, 20 ] },
        'official_name' => 'Test Country Official',
        'capital' => 'Test Capital',
        'region' => 'Test Region',
        'subregion' => 'Test Subregion',
        'population' => 1000000,
        'area' => 100000,
        'currencies' => { 'TST' => { 'name' => 'Test Currency', 'symbol' => 'T' } },
        'languages' => { 'tst' => 'Test Language' },
        'callingCode' => '+123',
        'timezones' => [ 'UTC+0' ],
        'borders' => [ 'ABC' ],
        'flag' => { 'large' => 'https://flag.png' }
      }
    end

    it 'extracts all attributes correctly' do
      result = service.send(:extract_country_attributes, country_data)

      expect(result[:name]).to eq('Test Country')
      expect(result[:alpha2_code]).to eq('TC')
      expect(result[:alpha3_code]).to eq('TST')
      expect(result[:latitude]).to eq('10')
      expect(result[:longitude]).to eq('20')
      expect(result[:official_name]).to eq('Test Country Official')
      expect(result[:capital]).to eq('Test Capital')
      expect(result[:region]).to eq('Test Region')
      expect(result[:subregion]).to eq('Test Subregion')
      expect(result[:population]).to eq('1000000')
      expect(result[:area]).to eq('100000')
      expect(result[:calling_code]).to eq('+123')
      expect(result[:flag]).to eq('https://flag.png')
    end

    it 'handles missing nested data gracefully' do
      country_data['latLng'] = nil
      country_data['flag'] = nil

      result = service.send(:extract_country_attributes, country_data)

      expect(result[:latitude]).to be_nil
      expect(result[:longitude]).to be_nil
      expect(result[:flag]).to be_nil
    end

    it 'uses fallback flag URLs' do
      country_data['flag'] = { 'medium' => 'https://flag-medium.png' }

      result = service.send(:extract_country_attributes, country_data)

      expect(result[:flag]).to eq('https://flag-medium.png')
    end
  end

  describe '#extract_currencies' do
    context 'with hash data' do
      let(:currencies_data) do
        {
          'USD' => { 'name' => 'US Dollar', 'symbol' => '$' },
          'EUR' => { 'name' => 'Euro', 'symbol' => '€' }
        }
      end

      it 'formats currencies correctly' do
        result = service.send(:extract_currencies, currencies_data)
        expect(result).to eq('USD: US Dollar ($), EUR: Euro (€)')
      end

      it 'handles non-hash currency info' do
        currencies_data['BTC'] = 'Bitcoin'
        result = service.send(:extract_currencies, currencies_data)
        expect(result).to include('BTC')
      end
    end

    context 'with non-hash data' do
      it 'converts string to string' do
        result = service.send(:extract_currencies, 'USD')
        expect(result).to eq('USD')
      end

      it 'converts array to string' do
        result = service.send(:extract_currencies, [ 'USD', 'EUR' ])
        expect(result).to eq('["USD", "EUR"]')
      end
    end

    context 'with blank data' do
      it 'returns nil for nil' do
        result = service.send(:extract_currencies, nil)
        expect(result).to be_nil
      end

      it 'returns nil for empty string' do
        result = service.send(:extract_currencies, '')
        expect(result).to be_nil
      end

      it 'returns nil for empty hash' do
        result = service.send(:extract_currencies, {})
        expect(result).to be_nil
      end
    end
  end

  describe '#extract_languages' do
    context 'with hash data' do
      let(:languages_data) do
        {
          'eng' => 'English',
          'spa' => 'Spanish'
        }
      end

      it 'formats languages correctly' do
        result = service.send(:extract_languages, languages_data)
        expect(result).to eq('eng: English, spa: Spanish')
      end
    end

    context 'with non-hash data' do
      it 'converts string to string' do
        result = service.send(:extract_languages, 'English')
        expect(result).to eq('English')
      end

      it 'converts array to string' do
        result = service.send(:extract_languages, [ 'eng', 'spa' ])
        expect(result).to eq('["eng", "spa"]')
      end
    end

    context 'with blank data' do
      it 'returns nil for nil' do
        result = service.send(:extract_languages, nil)
        expect(result).to be_nil
      end

      it 'returns nil for empty string' do
        result = service.send(:extract_languages, '')
        expect(result).to be_nil
      end

      it 'returns nil for empty hash' do
        result = service.send(:extract_languages, {})
        expect(result).to be_nil
      end
    end
  end

  describe '#safe_join' do
    context 'with array data' do
      it 'joins array with separator' do
        result = service.send(:safe_join, [ 'a', 'b', 'c' ], '|')
        expect(result).to eq('a|b|c')
      end

      it 'uses default separator' do
        result = service.send(:safe_join, [ 'a', 'b', 'c' ])
        expect(result).to eq('a, b, c')
      end
    end

    context 'with non-array data' do
      it 'converts string to string' do
        result = service.send(:safe_join, 'test')
        expect(result).to eq('test')
      end

      it 'converts number to string' do
        result = service.send(:safe_join, 123)
        expect(result).to eq('123')
      end
    end

    context 'with blank data' do
      it 'returns nil for nil' do
        result = service.send(:safe_join, nil)
        expect(result).to be_nil
      end

      it 'returns nil for empty string' do
        result = service.send(:safe_join, '')
        expect(result).to be_nil
      end

      it 'returns nil for empty array' do
        result = service.send(:safe_join, [])
        expect(result).to be_nil
      end
    end
  end

  describe '#log_results' do
    let(:stats) { { created: 5, updated: 3, errors: 1 } }

    before do
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:warn)
    end

    it 'logs completion message with stats' do
      service.send(:log_results, stats)

      expect(Rails.logger).to have_received(:info).with(
        I18n.t('country_update.service.completed', created: 5, updated: 3, errors: 1)
      )
    end

    it 'logs warning when there are errors' do
      service.send(:log_results, stats)

      expect(Rails.logger).to have_received(:warn).with(
        I18n.t('country_update.service.countries_failed', count: 1)
      )
    end

    it 'does not log warning when there are no errors' do
      stats[:errors] = 0
      service.send(:log_results, stats)

      expect(Rails.logger).not_to have_received(:warn)
    end
  end
end
