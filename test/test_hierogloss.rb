require 'minitest_helper'

class TestHierogloss < MiniTest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Hierogloss::VERSION
  end
end
