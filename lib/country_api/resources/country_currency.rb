# frozen_string_literal: true

module CountryApi
  module Resources
    class CountryCurrency < CountryApi::Resources::Base
      RESOURCE_NAME = "/api/currency"

      def fetch(currency)
        @connection.get("#{RESOURCE_NAME}/#{currency.to_s.downcase.strip}")
      end
    end
  end
end
