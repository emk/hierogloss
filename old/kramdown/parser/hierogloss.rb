require_relative '../../gloss'

module Kramdown
  module Parser
    class Hierogloss < ::Kramdown::Parser::Kramdown
      def initialize(source, options)
        super
        @span_parsers.unshift(:translit)
        @block_parsers.unshift(:gloss)
      end

      TRANSLIT_START = /{.*?}/
    
      def parse_translit
        @src.pos += @src.matched_size
        mdc = @src.matched[1..-2]
        em = Element.new(:em, nil, 'class' => 'transliteration')
        em.children << Element.new(:text, TransliterationRow.fancy(mdc))
        @tree.children << em
      end
      define_parser(:translit, TRANSLIT_START, '{')

      GLOSS_START = /^(U|L|G|T):/
      GLOSS_MATCH = /((^(U|L|G|T):.*)\r?\n)*/

      def parse_gloss
        start_line_number = @src.current_line_number
        data = @src.scan(self.class::GLOSS_MATCH)
        @tree.children.concat(Gloss.new(data).to_kramdown)
        true
      end

      define_parser(:gloss, GLOSS_START)
    end
  end
end