# -*- coding: utf-8 -*-

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'test/unit'
require_relative 'kramdown/parser/hierogloss'
require_relative 'kramdown/converter/bbcode'

class TestKramdownConverterBbcode < Test::Unit::TestCase
  def assert_bbcode(bbcode, text)
    assert_equal(bbcode,
                 Kramdown::Document.new(text, input: 'hierogloss').to_bbcode)
  end

  def test_should_process_paragraphs
    assert_bbcode("Hello", "Hello")
    assert_bbcode("Hello\n\nThere", "Hello\n\nThere")
  end

  def test_should_process_styling_tags
    assert_bbcode("[i]Hello[/i]", "_Hello_")
    assert_bbcode("[b]Hello[/b]", "**Hello**")
  end

  def test_should_process_links
    assert_bbcode("[url=http://example.com]here[/url]",
                  "[here](http://example.com)")
  end

  def test_should_handle_inline_transliteration
    assert_bbcode("[i]mꜣꜥ ḫrw[/i]", "{mAa xrw}")
  end
end
