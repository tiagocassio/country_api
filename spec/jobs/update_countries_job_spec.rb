require 'rails_helper'

RSpec.describe UpdateCountriesJob, type: :job do
  describe '#perform' do
    let(:job) { described_class.new }

    before do
      allow(CountryUpdateService).to receive(:update_all).and_return(true)
    end

    it 'calls the CountryUpdateService' do
      expect(CountryUpdateService).to receive(:update_all)
      job.perform
    end

    it 'logs the start and completion' do
      allow(Rails.logger).to receive(:info)

      expect(Rails.logger).to receive(:info).with(I18n.t('country_update.job.starting'))
      expect(Rails.logger).to receive(:info).with(I18n.t('country_update.job.completed'))

      job.perform
    end

    context 'when the service raises an error' do
      before do
        allow(CountryUpdateService).to receive(:update_all).and_raise(StandardError, 'API Error')
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error and re-raises it' do
        expect(Rails.logger).to receive(:error).with(I18n.t('country_update.job.failed', message: 'API Error'))
        expect { job.perform }.to raise_error(StandardError, 'API Error')
      end
    end
  end
end
