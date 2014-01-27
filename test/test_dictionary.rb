# -*- coding: utf-8 -*-
require 'minitest_helper'

class TestDictionary < Minitest::Test
  def assert_hw(headword, word)
    assert_equal(headword, Hierogloss::Dictionary.headword(word))
  end

  def test_should_leave_simple_headwords_alone
    assert_hw("xr", "xr")
    assert_hw("Hr", "Hr")
  end

  def test_should_strip_parens
    assert_hw("ny", "n(y)")
    assert_hw("mAa-Hrw", "mAa(-Hrw)")
  end

  def test_should_strip_clitics
    assert_hw("ir", "ir=n")
    assert_hw("im", "im=s")
  end

  def test_should_remove_dot_before_t
    assert_hw("Sspt", "Ssp.t")
    assert_hw("Hmt", "Hm.t")
  end

  def test_should_strip_plurals
    assert_hw("Sspt", "Ssp.wt")
    assert_hw("hrw", "hrw.w")
  end

  def test_should_strip_verb_endings
    assert_hw("ir", "ir.n=f")
    assert_hw("Dd", "Dd.n")
  end

  def test_should_provide_gardiner_signs_for_most_signs
    assert_equal("A1", Hierogloss::Dictionary.sign_to_gardiner("𓀀"))
    assert_equal("D4", Hierogloss::Dictionary.sign_to_gardiner("𓁹"))
  end

  def test_should_convert_variant_signs_to_gardiner
    # These signs aren't in the Unicode table.
    assert_equal("E8A", Hierogloss::Dictionary.sign_to_gardiner("𓃚"))
    assert_equal("N33A", Hierogloss::Dictionary.sign_to_gardiner("𓈓"))
    assert_equal("N35A", Hierogloss::Dictionary.sign_to_gardiner("𓈗"))
    assert_equal("P1A", Hierogloss::Dictionary.sign_to_gardiner("𓊜"))
    assert_equal("Y1\\r1", Hierogloss::Dictionary.sign_to_gardiner("𓏜"))
  end
end
