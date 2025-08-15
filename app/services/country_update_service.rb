class CountryUpdateService
  def self.update_all
    new.update_all
  end

  def update_all
    Rails.logger.info I18n.t("country_update.service.starting")

    client = CountryApi::Client.new
    countries_data = client.v1.all_countries

    if countries_data
      process_countries(countries_data)
    else
      Rails.logger.error I18n.t("country_update.service.failed_fetch")
      raise I18n.t("country_update.service.failed_fetch")
    end
  end

  private

  def process_countries(countries_data)
    stats = { created: 0, updated: 0, errors: 0 }

    countries_data.each do |country_code, country_data|
      begin
        process_single_country(country_data, stats)
      rescue => e
        stats[:errors] += 1
        Rails.logger.error I18n.t("country_update.countries.processing_error", code: country_code, message: e.message)
      end
    end

    log_results(stats)
    stats
  end

  def process_single_country(country_data, stats)
    country_attrs = extract_country_attributes(country_data)

    country = Country.find_or_create_by!(alpha2_code: country_attrs[:alpha2_code]) do |c|
      country_attrs.each { |key, value| c.send("#{key}=", value) if c.respond_to?("#{key}=") }
      stats[:created] += 1
    end

    if country.persisted? && country.updated_at < 1.day.ago
      country.update!(country_attrs)
      stats[:updated] += 1
      Rails.logger.info I18n.t("country_update.countries.updated", name: country.name)
    elsif country.new_record?
      Rails.logger.info I18n.t("country_update.countries.created", name: country.name)
    end
  end

  def extract_country_attributes(country_data)
    {
      name: country_data["name"],
      alpha2_code: country_data["alpha2Code"],
      alpha3_code: country_data["alpha3Code"],
      latitude: country_data.dig("latLng", "country", 0)&.to_s,
      longitude: country_data.dig("latLng", "country", 1)&.to_s,
      official_name: country_data["official_name"],
      capital: country_data["capital"],
      region: country_data["region"],
      subregion: country_data["subregion"],
      population: country_data["population"]&.to_s,
      area: country_data["area"]&.to_s,
      currencies: extract_currencies(country_data["currencies"]),
      language: extract_languages(country_data["languages"]),
      calling_code: country_data["callingCode"],
      time_zones: safe_join(country_data["timezones"]),
      borders: safe_join(country_data["borders"]),
      flag: country_data.dig("flag", "large") || country_data.dig("flag", "medium") || country_data.dig("flag", "small")
    }.compact
  end

  def extract_currencies(currencies_data)
    return nil if currencies_data.blank?

    if currencies_data.is_a?(Hash)
      currencies_data.map do |code, currency_info|
        if currency_info.is_a?(Hash)
          "#{code}: #{currency_info['name']} (#{currency_info['symbol']})"
        else
          code.to_s
        end
      end.join(", ")
    else
      currencies_data.to_s
    end
  end

  def extract_languages(languages_data)
    return nil if languages_data.blank?

    if languages_data.is_a?(Hash)
      languages_data.map do |code, language_name|
        "#{code}: #{language_name}"
      end.join(", ")
    else
      languages_data.to_s
    end
  end

  def safe_join(data, separator = ", ")
    return nil if data.blank?
    data.is_a?(Array) ? data.join(separator) : data.to_s
  end

  def log_results(stats)
    Rails.logger.info I18n.t("country_update.service.completed",
                             created: stats[:created],
                             updated: stats[:updated],
                             errors: stats[:errors])

    if stats[:errors] > 0
      Rails.logger.warn I18n.t("country_update.service.countries_failed", count: stats[:errors])
    end
  end
end
