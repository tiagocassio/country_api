# frozen_string_literal: true

module CountryApi
  module Resources
    class CountryName < CountryApi::Resources::Base
      RESOURCE_NAME = "/api/name"

      def fetch(name)
        @connection.get("#{RESOURCE_NAME}/#{name.to_s.downcase.strip}")
      end
    end
  end
end
