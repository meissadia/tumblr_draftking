require_relative 'test_helper'

class TestQueue < Minitest::Test
  @@client    = TestData.connect_to_client # Make one connection to reduce overhead
  @@test_data = load_draft_data

  def setup
    @dk = @@client.dup # Duplicate connection to avoid conflicts
  end

  def test_move_to_drafts
    draft_data = @@test_data.dup
    options = { filter: 'test_tag', test_data: draft_data }

    assert_equal 1, @dk.move_to_drafts(options), 'One queue should not pass filter'
  end
end
