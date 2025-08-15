# frozen_string_literal: true

module CountryApi
  module Resources
    class CountryRegion < CountryApi::Resources::Base
      RESOURCE_NAME = "/api/regionbloc"

      def fetch(region)
        @connection.get("#{RESOURCE_NAME}/#{region.to_s.downcase.strip}")
      end
    end
  end
end
