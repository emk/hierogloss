# -*- coding: utf-8 -*-
module Kramdown
  module Parser
    class Hierogloss < ::Kramdown::Parser::Kramdown
      def initialize(source, options)
        super
        @span_parsers.unshift(:translit)
        @block_parsers.unshift(:gloss)
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

      GLOSS_START = /^(U|L|G|T):/
      GLOSS_MATCH = /((^(U|L|G|T):.*)\r?\n)*/

      def parse_gloss
        start_line_number = @src.current_line_number
        data = @src.scan(self.class::GLOSS_MATCH)
        @tree.children <<
          new_block_el(:gloss, data, nil, :location => start_line_number)
        true
      end

      define_parser(:gloss, GLOSS_START)
    end
  end
end
