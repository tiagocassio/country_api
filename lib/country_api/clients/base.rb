# frozen_string_literal: true

module CountryApi
  module Clients
    class Base
      attr_accessor :connection

      def initialize(connection)
        @connection = connection
      end

      def fetch
        raise NotImplementedError
      end

      def get(_id)
        raise NotImplementedError
      end

      def post(_body)
        raise NotImplementedError
      end

      def put(_id, _body)
        raise NotImplementedError
      end

      def patch(_id, _body)
        raise NotImplementedError
      end

      def delete(_id)
        raise NotImplementedError
      end

      private

      def fetch_resource(resource, cache_key, param = nil)
        Rails.cache.fetch([ "country_api", cache_key, param ].compact.join("_"), expires_in: 5.minutes) do
          response = resource.new(connection).fetch(param)
          response.body
        end
      rescue Faraday::Error => e
        Rails.logger.error "Failed to fetch data from API: #{e.message}"
        nil
      end
    end
  end
end
