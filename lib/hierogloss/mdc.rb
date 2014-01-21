require 'parslet'

module Hierogloss
  module MdC
    class Parser < Parslet::Parser
      # Whitespace and equivalent delimiters.
      rule(:space) { match('[-_ ]').repeat(1) }
      rule(:space?) { space.maybe }

      # Signs.
      rule(:alpha_sign) { match('[A-Za-z0-9]').repeat(1) }
      rule(:unicode_sign) { match('[\u{13000}-\u{1342F}]') }
      rule(:sign) { (alpha_sign | unicode_sign).as(:sign) >> space? }

      # "Terminal" chunks in our expression grammar, which will match
      # an actual, concrete symbol.
      rule(:terminal) { sign }

      # A list of items with separators between them.
      def separated(item, separator)
        (item.as(:head) >> (separator >> item).repeat.as(:rest))
      end

      # Nested lists of signs separated by "*".
      rule(:juxtaposed) { separated(terminal, str('*')).as(:juxtaposed) }

      # Stacks of signs separated by ":".
      rule(:stack) { separated(juxtaposed, str(':')).as(:stack) }

      rule(:sequence) { stack.repeat }
      root(:sequence)
    end

    class Transform < Parslet::Transform
      # Prune out unused chunks of structure.
      def self.maybe_unpack(list, label=nil)
        if list.length == 1
          list.first
        elsif label
          [label].concat(list)
        else
          list
        end
      end

      rule(head: subtree(:head), rest: subtree(:rest)) { [head].concat(rest) }
      rule(sign: simple(:sign)) { sign }
      rule(stack: subtree(:list)) {|d| maybe_unpack(d[:list], :stack) }
      rule(juxtaposed: subtree(:list)) {|d| maybe_unpack(d[:list]) }
    end

    def self.parse(input)
      parsed = Parser.new.parse(input)
      Transform.new.apply(parsed)
    end
  end
end
