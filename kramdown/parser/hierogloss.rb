# -*- coding: utf-8 -*-
module Kramdown
  module Parser
    class Hierogloss < ::Kramdown::Parser::Kramdown
      def initialize(source, options)
        super
        @span_parsers.unshift(:translit)
      end

      JR_TRANSLITERATION = {
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
    
      TRANSLIT_START = /{.*?}/
    
      def parse_translit
        @src.pos += @src.matched_size
        mdc = @src.matched[1..-2]
        text = mdc.chars.map {|c| JR_TRANSLITERATION[c] || c }.join
        em = Element.new(:em)
        em.children << Element.new(:text, text)
        @tree.children << em
      end
      define_parser(:translit, TRANSLIT_START, '{')
    end
  end
end
