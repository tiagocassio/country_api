# frozen_string_literal: true

module CountryApi
  module Resources
    class CountryLanguage < CountryApi::Resources::Base
      RESOURCE_NAME = "/api/language"

      def fetch(language)
        @connection.get("#{RESOURCE_NAME}/#{language.to_s.downcase.strip}")
      end
    end
  end
end
