# frozen_string_literal: true

module CountryApi
  module Clients
    module V1
      class Client < CountryApi::Clients::Base
        def all_countries
          fetch_resource(CountryApi::Resources::Countries, "all_countries")
        end

        def of_calling_code(calling_code)
          fetch_resource(CountryApi::Resources::CountryCallingCode, "calling_code", calling_code)
        end

        def of_capital(capital_name)
          fetch_resource(CountryApi::Resources::CountryCapital, "capital_name", capital_name)
        end

        def of_language(language_code)
          fetch_resource(CountryApi::Resources::CountryLanguage, "language_code", language_code)
        end

        def of_name(country_name)
          fetch_resource(CountryApi::Resources::CountryName, "name", country_name)
        end
      end
    end
  end
end
