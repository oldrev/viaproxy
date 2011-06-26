#encoding: utf-8
#
require 'bigdecimal'

module ViaProxy

  module InternalFilters
    
    module AsciiToInteger
      NAME = 'atoi' 
      def self.encode(data)
        return data.to_s()
      end

      def self.decode(data)
        return data.to_i()
      end
    end

    module AsciiToFloat
      NAME = 'atof' 
      def self.encode(data)
        return data.to_s()
      end

      def self.decode(data)
        return data.to_f()
      end
    end

    module AsciiToDecimal
      NAME = 'atod' 
      def self.encode(data)
        return data.to_s('F')
      end

      def self.decode(data)
        return BigDecimal.new(data)
      end
    end

  end

end
