# frozen_string_literal: true

module CountryApi
  module Resources
    class CountryCallingCode < CountryApi::Resources::Base
      RESOURCE_NAME = "/api/callingcode"

      def fetch(calling_code)
        @connection.get("#{RESOURCE_NAME}/#{calling_code.to_s.downcase.strip}")
      end
    end
  end
end
