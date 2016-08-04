require_relative 'test_helper'

class TestPatches < Minitest::Test
  def test_thor
    refute Thor.new.print_wrapped('')
  end
end
