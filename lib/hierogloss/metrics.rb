# -*- coding: utf-8 -*-

module Hierogloss
  # :nodoc: Internal utilities for measuring hieroglyphs for layout
  # purposes.
  class Metrics
    # The nominal size of a quadrat relative to Data::SIGN_SIZES.
    QUADRAT_DATA_SIZE = 0.55

    # The nominal size of a quadrat in our API units.
    QUADRAT_SIZE = 12

    # A conversion factor.
    QUADRAT_CONV = QUADRAT_SIZE / QUADRAT_DATA_SIZE

    class << self
      def find(char)
        size = Data::SIGN_SIZES[char]
        new(conv(size[0]),conv(size[1]))
      end
      
      protected

      # Round things to reasonable sizes.  This is ad hoc and will require
      # extensive adjustment.
      def conv(x)
        rounded = (x*QUADRAT_CONV).round
        case rounded
        when 1..4 then 3
        when 5..7 then 6
        when 8..9 then 9
        when 10..14 then 12
        else rounded
        end
      end
    end

    attr_reader :width, :height

    def initialize(width, height)
      @width = width
      @height = height
    end
  end
end

require "hierogloss/metrics/data"
