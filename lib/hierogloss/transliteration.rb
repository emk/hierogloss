# -*- coding: utf-8 -*-
module Hierogloss
  # :nodoc: Transliteration utilities.
  module Transliteration
    STYLES = {
      # Output as raw MdC.  Useful when the user isn't expected to have any
      # fonts.
      mdc: {},

      # This is widely used in places like Allen, Loprieno and Thesaurus
      # Linguae Aegyptiae.
      jy_unicode: {
        "A" => "ꜣ",
        "i" => "j",
        "a" => "ꜥ",
        "H" => "ḥ",
        "x" => "ḫ",
        "X" => "ẖ",
        "S" => "š",
        "q" => "ḳ",
        "K" => "ḳ",
        "T" => "ṯ",
        "D" => "ḏ"
      }
    }

    # Convert from MDC to another transliteration style.  Defaults to
    # :jy_unicode.
    def self.render(mdc, style=nil)
      style ||=:jy_unicode
      conv = STYLES[style]
      raise "Unknown transliteration style: #{style}" unless conv
      mdc.chars.map {|c| conv[c] || c }.join
    end
  end
end
