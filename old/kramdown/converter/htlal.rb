module Kramdown
  module Converter
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
        inner(el, opts).each do |td|
          spaced << td << " | "
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