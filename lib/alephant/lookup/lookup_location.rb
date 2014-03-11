require 'crimp'

module Alephant
  module Lookup
    class LookupLocation
      attr_reader :component_id, :component_key, :opts, :opts_hash, :batch_version
      attr_accessor :location

      def initialize(component_id, batch_version, opts, location = nil)
        @component_id = component_id
        @batch_version = batch_version
        @opts = opts
        @opts_hash = hash_for(opts)
        @location = location
      end

      def component_key
        "#{component_id}/#{opts_hash}"
      end

      private

      def hash_for(opts)
        Crimp.signature opts
      end

    end
  end
end
