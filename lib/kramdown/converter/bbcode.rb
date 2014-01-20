module Kramdown
  module Converter
    # Outputs some of the most common Markdown elements as BBCode.
    # Everything in this class is internal.
    class Bbcode < Base
      include ::Kramdown::Utils::Html

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

      def convert_header(el, opts)
        tag("b", nil, inner(el, opts)) + ["\n"]
      end

      def convert_p(el, opts)
        inner(el, opts) + ["\n"]
      end

      def convert_blank(el, opts)
        "\n"
      end

      def convert_text(el, opts)
        # Wouldn't it be nice if we could escape BBCode?
        el.value.gsub(/\s+/, ' ') # Ignore newlines in raw text.
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

      def convert_smart_quote(el, opts)
        entity_to_str(smart_quote_entity(el))
      end

      def convert_table(el, opts)
        tag("table", nil, ["\n"] + inner(el, opts))
      end

      def convert_tbody(el, opts)
        inner(el, opts)
      end

      def convert_tr(el, opts)
        tag("tr", nil, inner(el, opts)) + ["\n"]
      end

      def convert_td(el, opts)
        if @stack.last.first.attr['class'] == 'hgls-h'
          tag("td", nil, tag("size", "24", inner(el, opts)))
        else
          tag("td", nil, inner(el, opts))
        end
      end

      def convert_blockquote(el, opts)
        # No newline because BBCode will add one itself.  We also run
        # results_to_text so we can clean up trailing newlines.
        tag("quote", nil, results_to_text(inner(el, opts)))
      end

      def convert_codeblock(el, opts)
        # No newline because BBCode will add one itself.
        tag("code", nil, el.value.sub(/\n\z/, ''))
      end

      def convert_img(el, opts)
        tag("img", nil, el.attr['src'])
      end
      
      def convert_root(el, opts)
        results_to_text(inner(el, opts))
      end

      def tag(name, arg, content)
        if arg
          ["[#{name}=#{arg}]", content, "[/#{name}]"]
        else
          ["[#{name}]", content, "[/#{name}]"]
        end
      end

      def results_to_text(results)
        results.flatten.compact.join.sub(/\n+\z/, '')
      end
    end
  end
end
