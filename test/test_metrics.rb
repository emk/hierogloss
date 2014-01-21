# -*- coding: utf-8 -*-
require 'minitest_helper'

class TestMetrics < MiniTest::Test
  # For our purposes, an ordinary quadrat is 12 units by 12 units, mostly
  # because this allows us to use most small fractions (1/1 through 1/4)
  # easily.
  def assert_metrics(width, height, char)
    m = Hierogloss::Metrics.find(char)
    assert_equal width, m.width, "Expected width of #{char} to be #{width}"
    assert_equal height, m.height, "Expected hieght of #{char} to be #{height}"
  end

  def test_signs_should_have_plausible_metrics
    # These numbers are a bit arbitrary.  They're based on my
    # interpretation of common hieroglyphic layouts and the sizes of the
    # signs extracted from the Gardiner font.  The idea is that anything
    # adding up to 12x12 should make a nice square quadrat without any
    # further scaling.  The ultimate answer here, of course, is whatever
    # looks good.
    assert_metrics(9, 12, "𓀀")
    assert_metrics(6, 12, "𓁐")
    assert_metrics(3, 12, "𓋴")
    assert_metrics(12, 3, "𓈖")
    assert_metrics(12, 3, "𓆑")
    assert_metrics(12, 6, "𓂧")
    assert_metrics(12, 12, "𓆓")
  end
end
