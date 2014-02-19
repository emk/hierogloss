module Kramdown
  module Converter
    # Outputs some of the most common Markdown elements in a stripped down
    # BBCode dialect without table support or reliable font size control.
    # Everything in this class is internal.
    class Htlal < Bbcode
      include ::Kramdown::Utils::Html

      def convert_table(el, opts)
        inner(el, opts)
      end

      def convert_tbody(el, opts)
        inner(el, opts)
      end

      def convert_tr(el, opts)
        spaced = []
        if el.attr['class'] == 'hgls-h'
          sep = " &nbsp; "
        else
          sep = " | "
        end
        inner(el, opts).each do |td|
          spaced << td << sep
        end
        spaced.pop
        spaced << "\n"
        spaced
      end

      def convert_td(el, opts)
        # We'd like to make hieroglyph cells bigger, but that doesn't play
        # nicely with links.
        inner(el, opts)
      end
    end
  end
end
