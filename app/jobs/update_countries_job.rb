class UpdateCountriesJob < ApplicationJob
  queue_as :default

    def perform
    Rails.logger.info I18n.t("country_update.job.starting")

    begin
      CountryUpdateService.update_all
      Rails.logger.info I18n.t("country_update.job.completed")
    rescue => e
      Rails.logger.error I18n.t("country_update.job.failed", message: e.message)
      raise e
    end
  end
end
