module CountryApi
  module Resources
    class Countries < CountryApi::Resources::Base
      RESOURCE_NAME = "/api/all"

      def initialize(connection)
        @connection = connection
      end

      def fetch(param = nil)
        @connection.get(RESOURCE_NAME)
      end
    end
  end
end
