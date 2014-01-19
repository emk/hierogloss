module Kramdown
  module Converter
    class Bbcode < Base
      DISPATCHER = Hash.new {|h,k| h[k] = "convert_#{k}"} #:nodoc:

      def initialize(root, options)
        super
        @stack = []
      end

      def convert(el, opts = {})
        send(DISPATCHER[el.type], el, opts)
      end

      def inner(el, opts)
        @stack.push([el, opts])
        result = el.children.map do |inner_el|
          convert(inner_el, options)
        end
        @stack.pop
        result
      end

      def convert_p(el, opts)
        inner(el, opts) + ["\n"]
      end

      def convert_blank(el, opts)
        "\n"
      end

      def convert_text(el, opts)
        # Wouldn't it be nice if we could escape BBCode?
        el.value
      end

      def convert_em(el, opts)
        tag("i", nil, inner(el, opts))
      end

      def convert_strong(el, opts)
        tag("b", nil, inner(el, opts))
      end

      def convert_a(el, opts)
        tag("url", el.attr['href'], inner(el, opts))
      end

      def convert_root(el, opts)
        inner(el, opts).flatten.compact.join.sub(/\n+\z/, '')
      end

      def tag(name, arg, content)
        if arg
          ["[#{name}=#{arg}]", content, "[/#{name}]"]
        else
          ["[#{name}]", content, "[/#{name}]"]
        end
      end
    end
  end
end
