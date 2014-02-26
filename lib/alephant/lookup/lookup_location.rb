module Alephant
  module Lookup
    class LookupLocation
      S3_LOCATION_FIELD = 'location'

      attr_reader :component_id, :opts, :location

      def initialize(component_id, opts, location)
        @component_id = component_id
        @opts = opts
        @location = location
      end

      def to_h
        {
          :component_id => @component_id,
          :opts => opts,
          S3_LOCATION_FIELD => @location
        }
      end
    end
  end
end
