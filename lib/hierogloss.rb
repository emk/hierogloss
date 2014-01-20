require 'kramdown'
require "hierogloss/version"
require "hierogloss/dictionary"
require "hierogloss/gloss"
require "kramdown/parser/hierogloss"
require "kramdown/converter/bbcode"
# No guarantess of backwards compatibility for this one.
require "kramdown/converter/htlal"

# Most of our internal APIs are undocumented at this point, but you
# can use this gem via Kramdown's APIs.
#
#   Kramdown::Document.new(ARGF.read, input: 'hierogloss').to_html
#
# Or if you want to post on an online forum, try:
#
#   Kramdown::Document.new(ARGF.read, input: 'hierogloss').to_bbcode
#
# Note that the BBCode converter does not yet support all available
# Markdown constructs.  You're welcome to try other kramdown backends;
# some of them may more-or-less work.
module Hierogloss
  # Nothing to do here yet.
end
