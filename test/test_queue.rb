require_relative 'test_helper'

class TestQueue < Minitest::Test
  def test_move_to_drafts
    options = { filter: $test_comment, test_data: $test_data.dup, mute: true, keep_tree: true }
    msg = 'One queue should not pass filter'
    assert_equal 1, $client.move_to_drafts(options), msg
  end
end
