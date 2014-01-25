# -*- coding: utf-8 -*-
require 'minitest_helper'

class TestTransliteration < MiniTest::Test
  def assert_renders(output, input, type)
    assert_equal output, Hierogloss::Transliteration.render(input, type)
  end

  def test_should_render_common_tranliterations
    assert_renders "biA.t y", "biA.t y", :mdc
    assert_renders "bjꜣ.t y", "biA.t y", :jy_unicode
  end
end
