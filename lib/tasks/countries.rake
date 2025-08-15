namespace :countries do
  desc "Update all countries from the API"
  task update: :environment do
    Rails.logger.info I18n.t("country_update.rake.starting_update")
    UpdateCountriesJob.perform_now
    Rails.logger.info I18n.t("country_update.rake.update_completed")
  end

  desc "Update countries and show statistics"
  task update_with_stats: :environment do
    Rails.logger.info I18n.t("country_update.rake.starting_stats")

    initial_count = Country.count
    Rails.logger.info I18n.t("country_update.rake.initial_count", count: initial_count)

    UpdateCountriesJob.perform_now

    final_count = Country.count
    Rails.logger.info I18n.t("country_update.rake.final_count", count: final_count)
    Rails.logger.info I18n.t("country_update.rake.countries_added", count: final_count - initial_count)
    Rails.logger.info I18n.t("country_update.rake.update_completed")
  end

  desc "Check country data freshness"
  task check_freshness: :environment do
    Rails.logger.info I18n.t("country_update.rake.checking_freshness")

    countries = Country.all
    fresh_count = countries.where("updated_at > ?", 1.day.ago).count
    stale_count = countries.where("updated_at <= ?", 1.day.ago).count

    Rails.logger.info I18n.t("country_update.rake.total_countries", count: countries.count)
    Rails.logger.info I18n.t("country_update.rake.fresh_data", count: fresh_count)
    Rails.logger.info I18n.t("country_update.rake.stale_data", count: stale_count)

    if stale_count > 0
      Rails.logger.warn I18n.t("country_update.rake.run_update")
    end
  end
end
