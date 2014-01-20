# -*- coding: utf-8 -*-
require 'minitest_helper'

class TestGloss < MiniTest::Test
  include Hierogloss

  def setup
    input = <<EOD
U: 𓊃𓀀𓏤 | 𓊃𓏏𓁐
L: s | s.t
G: homme | femme
T: l'homme et la femme
EOD
    @gloss = Hierogloss::Gloss.new(input)
  end

  def assert_row(type, raw_cells, row)
    assert_instance_of(type, row)
    refute(row.span?)
    assert_equal(raw_cells, row.raw_cells)
  end

  def test_should_parse_gloss_into_appropriate_rows
    assert_equal(4, @gloss.rows.length)
    assert_row(UnicodeHieroglyphRow, ["𓊃𓀀𓏤", "𓊃𓏏𓁐"], @gloss.rows[0])
    assert_row(TransliterationRow, ["s", "s.t"], @gloss.rows[1])
    assert_row(Row, ["homme", "femme"], @gloss.rows[2])

    # Translations don't have cells.
    assert_instance_of(TranslationRow, @gloss.rows[3])
    assert(@gloss.rows[3].span?)
    assert_equal("l'homme et la femme", @gloss.rows[3].text)
  end
  
  def test_should_be_convertible_to_a_list_of_kramdown_elements
    # We don't actually care what's in there; we just want to render
    # something plausible.
    kramdown = @gloss.to_kramdown
    assert_instance_of(Array, kramdown)
    assert(kramdown.length > 0)
    kramdown.each {|k| assert_instance_of(Kramdown::Element, k) }
  end
end