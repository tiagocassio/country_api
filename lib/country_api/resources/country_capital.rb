# frozen_string_literal: true

module CountryApi
  module Resources
    class CountryCapital < CountryApi::Resources::Base
      RESOURCE_NAME = "/api/capital"

      def fetch(capital)
        @connection.get("#{RESOURCE_NAME}/#{capital.to_s.downcase.strip}")
      end
    end
  end
end
