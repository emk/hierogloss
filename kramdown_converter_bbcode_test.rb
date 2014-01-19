# -*- coding: utf-8 -*-

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'test/unit'
require_relative 'kramdown/parser/hierogloss'
require_relative 'kramdown/converter/bbcode'

class TestKramdownConverterBbcode < Test::Unit::TestCase
  def assert_bbcode(bbcode, text)
    actual = Kramdown::Document.new(text, input: 'hierogloss').to_bbcode
    assert_equal(bbcode, actual)
  end

  def test_should_process_paragraphs
    assert_bbcode("Hello", "Hello")
    assert_bbcode("Hello\n\nThere", "Hello\n\nThere")
  end

  def test_should_process_headers
    assert_bbcode("[b]Hello[/b]", "# Hello")
  end

  def test_should_process_blockquotes
    assert_bbcode("[quote]Hello there[/quote]", "> Hello\n> there")
  end

  def test_should_process_codeblocks
    assert_bbcode("[code]Hello\nthere[/code]", "    Hello\n    there")
  end

  def test_should_process_image
    assert_bbcode("[img]http://example.com/f.png[/img]",
                  "![](http://example.com/f.png)")
  end

  def test_should_process_styling_tags
    assert_bbcode("[i]Hello[/i]", "_Hello_")
    assert_bbcode("[b]Hello[/b]", "**Hello**")
  end

  def test_should_process_links
    assert_bbcode("[url=http://example.com]here[/url]",
                  "[here](http://example.com)")
  end

  def test_should_process_smart_quotes
    assert_bbcode("A “foo” ", "A \"foo\" ")
  end

  def test_should_handle_inline_transliteration
    assert_bbcode("[i]mꜣꜥ ḫrw[/i]", "{mAa xrw}")
  end

  def test_should_handle_gloss_blocks
    gloss = <<EOD
U: 𓇋𓀀 | 𓁐
G: homme | femme
EOD
    table = <<EOD.sub(/\n$/, '')
[table]
[tr][td][size=24]𓇋[url=http://www.hierogl.ch/hiero/Sp%C3%A9cial:Recherche?search=Signe%3AA1&go=Lire]𓀀[/url][/size][/td][td][size=24][url=http://www.hierogl.ch/hiero/Sp%C3%A9cial:Recherche?search=Signe%3AB1&go=Lire]𓁐[/url][/size][/td][/tr]
[tr][td]homme[/td][td]femme[/td][/tr]
[/table]
EOD
    assert_bbcode(table, gloss)
  end
end
