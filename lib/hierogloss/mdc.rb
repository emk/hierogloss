require 'parslet'

module Hierogloss
  #:nodoc: Our parser for the Manuel de Codage format.
  module MdC
    class Block
      protected

      # This whole precedence business may need more test cases further work.
      def maybe_parens(current, context, str)
        if current < context
          "(#{str})"
        else
          str
        end
      end
    end

    class Sign < Block
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def to_unicode
        Hierogloss::Dictionary.mdc_to_sign(name) || name
      end

      def to_debug
        name
      end

      def to_linear_hieroglyphs
        to_unicode
      end

      def to_mdc(precedence)
        mdc = Hierogloss::Dictionary.sign_to_mdc(name) || name
        # Wrap composite signs in parens.
        return "(#{mdc})" if mdc =~ /[-:*]/
        mdc
      end
    end

    class Composed < Block
      attr_reader :base, :composed

      def initialize(base, composed)
        @base = base
        @composed = composed
      end

      def to_debug
        [:composed, base.to_debug, composed.to_debug]
      end

      def to_linear_hieroglyphs
        [base.to_linear_hieroglyphs, composed.to_linear_hieroglyphs]
      end

      def to_mdc(precedence)
        maybe_parens(3, precedence, "#{base.to_mdc(3)}&#{composed.to_mdc(3)}")
      end
    end

    class Group < Block
      attr_reader :blocks

      def initialize(blocks)
        @blocks = blocks
      end      

      def to_debug
        blocks.map {|b| b.to_debug }
      end

      def to_linear_hieroglyphs
        blocks.map {|b| b.to_linear_hieroglyphs }
      end
    end

    class Sequence < Group
      def to_mdc(precedence)
        maybe_parens(2, precedence, blocks.map {|b| b.to_mdc(2) }.join("*"))
      end
    end

    class Stack < Group
      def to_debug
        [:stack].concat(super)
      end

      def to_mdc(precedence)
        maybe_parens(1, precedence, blocks.map {|b| b.to_mdc(1) }.join(":"))
      end
    end

    class Quadrats < Group
      # Actually render to a string here.
      def to_linear_hieroglyphs
        super.flatten.join
      end

      def to_mdc
        blocks.map {|b| b.to_mdc(0) }.join("-")
      end

      def to_mdc_image_url
        esc = URI.escape(to_mdc, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        "http://i.hierogloss.net/mdc/#{esc}.png"
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

      # Signs with special composition behavior, as per JSesh.
      rule(:composed) { sign.as(:base) >> str('&') >> atomic.as(:composed) }

      # Parenthesized blocks.
      rule(:parens) { str('(') >> space? >> sequence >> str(')') >> space? }

      # "Terminal" chunks in our expression grammar, which will match
      # an actual, concrete symbol in the first position.
      rule(:atomic) { composed | sign | parens }

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
      rule(sign: simple(:sign)) { Sign.new(sign.to_s) }
      rule(base: simple(:base), composed: simple(:composed)) do
        Composed.new(base, composed)
      end
      rule(stack: subtree(:list)) {|d| lists_as(Stack, d[:list]) }
      rule(juxtaposed: subtree(:list)) {|d| lists_as(Sequence, d[:list]) }
    end

    def self.parse(input)
      parsed = Parser.new.parse(input)
      Quadrats.new(Transform.new.apply(parsed))
    end
  end
end
