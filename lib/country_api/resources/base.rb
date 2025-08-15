module CountryApi
  module Resources
    class Base
      def initialize(connection)
        @connection = connection
      end

      def fetch(param)
        raise NotImplementedError
      end
    end
  end
end
