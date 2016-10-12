require_relative 'test_helper'

class TestQueue < Minitest::Test
  def test_move_to_drafts
    options = { key_text: $test_comment, test_data: $test_data.dup, mute: true, keep_tree: true }
    msg = 'One queue should not pass key_text'
    assert_equal 1, $client.move_to_drafts(options).first, msg
  end
end
