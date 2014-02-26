module Alephant
  module Lookup
    class LookupLocation
      attr_reader :component_id, :opts, :location

      def initialize(component_id, opts, location)
        @component_id = component_id
        @opts = opts
        @location = location
      end
    end
  end
end
