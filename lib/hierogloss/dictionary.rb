# -*- coding: utf-8 -*-

module Hierogloss
  #:nodoc: Internal dictionary-related utilities.  APIs are not stable.
  module Dictionary
    DATA_DIR = File.join(File.dirname(__FILE__), '..', '..', 'data')
    MDC_MAPPING_PATH = File.join(DATA_DIR, "Unicode-MdC-Mapping-v1.utf8")

    # Pattern identifying Gardiner codes (as opposed to phonetic ones.
    GARDINER_REGEX = /\A[A-Z][0-9]+[A-Za-z]?([-:*\\].*)?\z/

    # Convert variant signs to something that should work in JSesh.
    def self.fix_gardiner(code)
      if code =~ GARDINER_REGEX
        code.upcase.sub(/\\R/, '\r')
      else
        code
      end
    end

    SIGN_TO_GARDINER = {}
    MDC_TO_SIGN = {}
    SIGN_TO_MDC = {}

    File.open(MDC_MAPPING_PATH, "r:bom|utf-8") do |f|
      f.each_line do |l|
        l.chomp!
        sign, hex, codes, remarks = l.split(/\t/, 4)
        for code in codes.split(/ /)
          code = fix_gardiner(code)
          MDC_TO_SIGN[code] = sign
          # Unliterals.
          SIGN_TO_MDC[sign] = code if code.length == 1
          # Gardiner codes, and composite signs starting with Gardiner codes.
          next unless code =~ GARDINER_REGEX
          SIGN_TO_GARDINER[sign] = code
          SIGN_TO_MDC[sign] ||= code
        end
      end
    end

    class << self
      # Try to kick things into shape for hierogl.ch.
      def headword(word)
        hw = word
        hw.gsub!(/[()]/, '')
        hw.sub!(/=.*\z/, '')
        hw.sub!(/\.w?t\z/, 't')
        hw.sub!(/\..*\z/, '')
        hw
      end

      # Given a Unicode hieroglyph, get the corresponding Gardiner sign.
      def sign_to_gardiner(sign)
        SIGN_TO_GARDINER[sign]
      end

      # Convert a Manuel de Codage transliteration to the corresponding Unicode
      # sign.
      def mdc_to_sign(mdc)
        MDC_TO_SIGN[mdc]
      end

      # Convert a Unicode hieroglyph to a reasonable MdC representation.
      def sign_to_mdc(sign)
        SIGN_TO_MDC[sign]
      end
    end
  end
end
