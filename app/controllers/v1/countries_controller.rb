module V1
  class CountriesController < ApplicationController
    before_action :set_country, only: %i[ show ]

    # GET /v1/countries
    # @api {get} /v1/countries List countries
    # @apiName GetCountries
    # @apiGroup Countries
    # @apiVersion 1.0.0
    # @apiDescription Retrieve a paginated list of countries with optional search filtering
    # @apiParam {String} [term] Search term to filter countries by name
    # @apiParam {Integer} [page=1] Page number for pagination
    # @apiParam {Integer} [items=20] Number of items per page
    # @apiSuccess {Object} data List of countries
    # @apiSuccess {Array} data.countries Array of country objects
    # @apiSuccess {Object} pagination Pagination information
    # @apiSuccess {Integer} pagination.count Total number of countries
    # @apiSuccess {Integer} pagination.page Current page number
    # @apiSuccess {Integer} pagination.items Items per page
    # @apiSuccess {Integer} pagination.pages Total number of pages
    # @apiError {Object} 401 Unauthorized - Invalid or missing authentication token
    # @apiError {Object} 422 Unprocessable Entity - Invalid search parameters
    def index
      country_filter_service = ::Filters::CountryFilter.new.filter(search_params)
      @pagy, @countries = pagy(country_filter_service.results, items: 20)
    end

    # GET /v1/countries/:id
    # @api {get} /v1/countries/:id Get country details
    # @apiName GetCountry
    # @apiGroup Countries
    # @apiVersion 1.0.0
    # @apiDescription Retrieve detailed information about a specific country
    # @apiParam {String} id Country identifier (slug)
    # @apiSuccess {Object} data Country object with full details
    # @apiSuccess {String} data.id Country identifier
    # @apiSuccess {String} data.name Country name
    # @apiSuccess {String} data.official_name Official country name
    # @apiSuccess {String} data.capital Capital city
    # @apiSuccess {String} data.region Geographic region
    # @apiSuccess {String} data.subregion Sub-region
    # @apiSuccess {Integer} data.population Population count
    # @apiSuccess {Number} data.area Land area in square kilometers
    # @apiSuccess {String} data.calling_code International calling code
    # @apiSuccess {String} data.currency Primary currency code
    # @apiSuccess {Array} data.languages Array of official languages
    # @apiSuccess {String} data.flag_url URL to country flag image
    # @apiError {Object} 401 Unauthorized - Invalid or missing authentication token
    # @apiError {Object} 404 Not Found - Country not found
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
