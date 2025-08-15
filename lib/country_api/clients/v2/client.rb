# frozen_string_literal: true

module CountryApi
  module Clients
    module V2
      class Client < CountryApi::Clients::Base
        def of_currency(currency_code)
          fetch_resource(CountryApi::Resources::CountryCurrency, "currency_code", currency_code)
        end

        def of_region(region_code)
          fetch_resource(CountryApi::Resources::CountryRegion, "region_code", region_code)
        end
      end
    end
  end
end
