require_relative 'test_helper'

class TestQueue < Minitest::Test
  def test_move_to_drafts
    options = { filter: $test_comment, test_data: $test_data.dup, mute: true }
    assert_equal 1, $client.move_to_drafts(options), 'One queue should not pass filter'
  end
end
