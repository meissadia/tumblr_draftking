require_relative 'test_helper'

class TestQueue < Minitest::Test
  @@client    = connect_to_client # Make one connection to reduce overhead
  @@test_data = load_draft_data

  def setup
    @dk = @@client.dup            # Duplicate connection to avoid conflicts
  end

  def test_move_to_drafts
    draft_data = @@test_data.dup
    expected   = draft_data.size
    assert_equal 93, expected
    @dk.d_size = 0
    @dk.q_size = expected
    d_after    = expected - 1
    options = { filter: 'test_tag', test_data: draft_data }
    @dk.move_to_drafts(options)

    assert_equal 1,       @dk.q_size, 'One queue should not pass filter'
    assert_equal d_after, @dk.d_size, 'Drafts has correct number of posts'
  end
end
