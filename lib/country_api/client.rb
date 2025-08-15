# frozen_string_literal: true

module CountryApi
  class Client
    BASE_URL = "https://countryapi.io"

    def initialize
      @api_key = Rails.application.credentials.country_api[:api_key]
    end

    def v1
      CountryApi::Clients::V1::Client.new(connection)
    end

    def v2
      CountryApi::Clients::V2::Client.new(connection)
    end

    private

    def connection
      @connection ||= Faraday.new(url: BASE_URL) do |faraday|
        faraday.request :url_encoded
        faraday.response :logger, nil, { headers: true, bodies: false, errors: true }
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter Faraday.default_adapter
        faraday.options.timeout = 5
        faraday.params["apikey"] = @api_key
      end
    end
  end
end
