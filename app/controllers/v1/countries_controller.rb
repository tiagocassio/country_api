module V1
  class CountriesController < ApplicationController
    before_action :set_country, only: %i[ show ]

    def index
      country_filter_service = ::Filters::CountryFilter.new.filter(search_params)
      @pagy, @countries = pagy(country_filter_service.results, items: 999)
    end

    def show; end

    private

    def search_params
      params.permit(:term)
    end

    def set_country
      @country = Country.friendly.find(params[:id])
    end
  end
end
