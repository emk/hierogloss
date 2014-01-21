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

  def assert_linear_hieroglyphs(expected, input)
    assert_equal(expected, Hierogloss::MdC.parse(input).to_linear_hieroglyphs)
  end

  def test_should_convert_mdc_to_linear_hieroglyphs
    assert_linear_hieroglyphs("𓆓𓂧𓈖", "𓆓:𓂧𓈖")
    assert_linear_hieroglyphs("𓊪𓏏𓏭𓇯", "p*(t:Z4):pt")
  end

  def assert_mdc(expected, input)
    assert_equal(expected, Hierogloss::MdC.parse(input).to_mdc)
  end

  def test_should_convert_mdc_to_mdc_string
    assert_mdc("D:d-n", "𓆓:𓂧𓈖")
    assert_mdc("p*(t:Z4):pt", "p*(t:Z4):pt")
    # Compound signs are always placed in parens.
    assert_mdc("(N33*N33:N33*N33)", "𓃌")
  end
end
