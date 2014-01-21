#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Requires ttfunk 1.1 to operate, which conflicts with the
# currently-released version of prawn.

require "ttfunk"

def metrics(file, codepoint)
  glyph_id = file.cmap.unicode.first[codepoint]
  return nil if glyph_id == 0
  glyph = file.glyph_outlines.for(glyph_id)
  [codepoint, glyph.x_max-glyph.x_min, glyph.y_max-glyph.y_min]
end

f = TTFunk::File.open(File.join(File.dirname(__FILE__), 'src', 'Gardiner.ttf'))

metrics = (0x13000..0x1342F).map {|cp| metrics(f, cp) }.compact
max_width = metrics.map {|m| m[1] }.max
max_height = metrics.map {|m| m[2] }.max

print <<EOD
# -*- coding: utf-8 -*-

# :nodoc: This file is generated automatically using dump_metrics.rb.
# It contains the relative width and height of each sign in the Gardiner.ttf
# font for use in layout algorithms.
module Hierogloss
  module Metrics
    module Data
      SIGN_SIZES = {
EOD

metrics.each do |cp, w, h|
  c = [cp].pack("U")
  printf "\"%s\"=>[%0.2f,%0.2f],\n", c, 1.0*w/max_width, 1.0*h/max_height
end

print <<EOD
      }
    end
  end
end
EOD
