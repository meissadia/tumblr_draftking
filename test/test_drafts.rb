require_relative 'test_helper'

class TestDrafts < Minitest::Test
  @@client    = TestData.connect_to_client # Make one connection to reduce overhead
  @@test_data = load_draft_data

  def setup
    @dk = @@client.dup # Duplicate connection to avoid conflicts
  end

  def test_comment_posts_all
    draft_data = @@test_data.dup
    expected   = draft_data.size
    options    = { comment: 'different comment', test_data: draft_data }
    tagged     = @dk.comment_posts(options)
    assert_equal expected, tagged, 'Add comment to all drafts'
  end

  def test_comment_posts_limit
    draft_data = @@test_data.dup
    expected   = 20
    options    = { comment: '001 comment', test_data: draft_data, limit: expected }
    tagged     = @dk.comment_posts(options)
    assert_equal expected, tagged, 'Comment some drafts'
  end

  def test_strip_comments
    opts = { test_data: @@test_data.dup }
    assert_equal 93, @dk.strip_old_comments(opts), 'All drafts have been modified'
  end

  def test_getdrafts
    # Valide Draft Numbers
    assert @dk.d_size >= 0, 'Draft size has been initialized'

    opts = { limit: 12 }
    assert @dk.getposts(opts).size <= 12, 'Get a specific number of drafts'

    opts = { test_data: @@test_data }
    assert @dk.getposts(opts).size == @@test_data.size, 'Use test data when present'

    assert @dk.getposts({}).size == @dk.d_size, 'Get all available drafts'
  end

  def test_status
    string = @dk.status
    pattern = /(\w*\s\w*:\s\d*\n+)*/
    refute_nil pattern.match(string)
  end

  def test_a_live_post
    d = @dk.some_posts(before_id: 0, limit: 1).first
    assert 0 <= DK::Post.new(d).save(client: @dk.client, simulate: false)
  end

  def test_drafts_to_queue
    draft_data = @@test_data.dup
    expected   = draft_data.size
    moved      = expected - 1
    options = { filter: 'test_tag', test_data: draft_data }

    assert_equal moved, @dk.drafts_to_queue(options), 'One draft should not pass filter'
  end
end
