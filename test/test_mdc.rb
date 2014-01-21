# -*- coding: utf-8 -*-
require 'minitest_helper'

class TestCodage < MiniTest::Test
  def assert_parse(expected, input)
    assert_equal(expected, Hierogloss::MdC.parse(input).to_debug)
  end

  def test_should_parse_separated_signs
    assert_parse(["i"], "i")
    assert_parse(["i", "A2"], "i-A2")
    assert_parse(["i", "A2"], "i A2")
    assert_parse(["i", "A2"], "i  A2")
    assert_parse(["i", "A2"], "i_A2")
    assert_parse(["i", "A2"], "i__A2")
    # A non-standard extension, but I rather like using a proper input
    # method to type hieroglyphs.
    assert_parse(["𓇋", "𓀁"], "𓇋𓀁")
  end

  def test_should_parse_stacked_signs
    assert_parse([[:stack, "D", "d"], "n"], "D:d-n")
    assert_parse([[:stack, "D", "d", "n"]], "D:d:n")
    assert_parse([[:stack, "𓆓", "𓂧"], "𓈖"], "𓆓:𓂧𓈖")
    assert_parse([[:stack, "𓆓", "𓂧", "𓈖"]], "𓆓:𓂧:𓈖")
  end

  def test_should_parse_juxtaposed_signs
    assert_parse([[:stack, "𓇾", ["𓏤", "𓈇"]]], "𓇾:𓏤*𓈇")
  end

  def test_should_honor_parens
    assert_parse([[:stack, ["p", [:stack, "t", "Z4"]], "pt"]], "p*(t:Z4):pt")
  end
end
