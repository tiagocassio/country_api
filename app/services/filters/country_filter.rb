module Filters
  class CountryFilter
    def initialize(countries = Country.all)
      @countries = countries
    end

    def filter(params = {})
      by_name(params[:name])
        .by_calling_code(params[:calling_code])
        .by_capital_name(params[:capital])
        .by_language(params[:language])
        .by_region(params[:region])
        .by_currency(params[:currency])
    end

    def by_name(name)
      return self if name.blank?

      @countries = @countries.where("countries.name ILIKE :term", term: "%#{name}%")
      self
    end

    def by_calling_code(calling_code)
      return self if calling_code.blank?

      @countries = @countries.where(calling_code: calling_code)
      self
    end

    def by_capital_name(capital_name)
      return self if capital_name.blank?

      @countries = @countries.where(capital: capital_name)
      self
    end

    def by_currency(currency)
      return self if currency.blank?

      @countries = @countries.where("countries.currencies ILIKE :term", term: "%#{currency}%")
      self
    end

    def by_language(language)
      return self if language.blank?

      @countries = @countries.where(language: language)
      self
    end

    def by_region(region)
      return self if region.blank?

      @countries = @countries.where(region: region)
      self
    end

    def results
      @countries
    end
  end
end
