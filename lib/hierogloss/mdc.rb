require 'parslet'

module Hierogloss
  #:nodoc: Our parser for the Manuel de Codage format.
  module MdC
    class Block
    end

    class Sign < Block
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def to_debug
        name
      end
    end

    class Sequence < Block
      attr_reader :blocks

      def initialize(blocks)
        @blocks = blocks
      end

      def to_debug
        blocks.map {|b| b.to_debug }
      end
    end

    class Stack < Block
      attr_reader :blocks

      def initialize(blocks)
        @blocks = blocks
      end

      def to_debug
        [:stack].concat(blocks.map {|b| b.to_debug })
      end
    end

    class Parser < Parslet::Parser
      # Whitespace and equivalent delimiters.
      rule(:space) { match('[-_ ]').repeat(1) }
      rule(:space?) { space.maybe }

      # Signs.
      rule(:alpha_sign) { match('[A-Za-z0-9]').repeat(1) }
      rule(:unicode_sign) { match('[\u{13000}-\u{1342F}]') }
      rule(:sign) { (alpha_sign | unicode_sign).as(:sign) >> space? }

      # Parenthesized blocks.
      rule(:parens) { str('(') >> space? >> sequence >> str(')') >> space? }

      # "Terminal" chunks in our expression grammar, which will match
      # an actual, concrete symbol in the first position.
      rule(:atomic) { sign | parens }

      # A list of items with separators between them.
      def separated(item, separator)
        (item.as(:head) >> (separator >> item).repeat.as(:rest))
      end

      # Nested lists of signs separated by "*".
      rule(:juxtaposed) { separated(atomic, str('*')).as(:juxtaposed) }

      # Stacks of signs separated by ":".
      rule(:stack) { separated(juxtaposed, str(':')).as(:stack) }

      rule(:sequence) { stack.repeat }
      root(:sequence)
    end

    class Transform < Parslet::Transform
      # If we only have one item, we don't need to build an extra wrapper
      # class; we can just pass it up.
      def self.lists_as(klass, list)
        if list.length == 1
          list.first
        else
          klass.new(list)
        end
      end

      rule(head: subtree(:head), rest: sequence(:rest)) { [head].concat(rest) }
      rule(sign: simple(:sign)) { Sign.new(sign) }
      rule(stack: subtree(:list)) {|d| lists_as(Stack, d[:list]) }
      rule(juxtaposed: subtree(:list)) {|d| lists_as(Sequence, d[:list]) }
    end

    def self.parse(input)
      parsed = Parser.new.parse(input)
      Sequence.new(Transform.new.apply(parsed))
    end
  end
end
