require_relative 'test_helper'

class TestDrafts < Minitest::Test
  def test_comment_posts_all
    draft_data = $test_data.dup
    expected   = draft_data.size
    options    = { comment: 'different comment', test_data: draft_data,
                   mute: true }
    tagged     = $client.comment_posts(options).first
    assert_equal expected, tagged, 'Add comment to all drafts'
  end

  def test_comment_posts_limit
    draft_data = $test_data.dup
    expected   = 20
    options = { comment: '001 comment', test_data: draft_data, limit: expected }
    tagged  = $client.comment_posts(options).first
    assert_equal expected, tagged, 'Comment some drafts'
  end

  def test_strip_comments
    opts = { test_data: $test_data.dup, mute: true }
    msg  = 'All drafts have been modified'
    assert_equal 93, $client.strip_old_comments(opts).first, msg
  end

  def test_getdrafts
    # Valide Draft Numbers
    $client.act_on_blog(name: $client.blog_name)
    assert $client.d_size >= 0, 'Draft size has been initialized'

    client = $client.dup
    client.limit     = 12
    client.test_data = nil
    assert client.get_posts.size <= 12, 'Get a specific number of drafts'

    msg = 'Use test data when present'
    client.limit     = nil
    client.test_data = $test_data.dup
    assert client.get_posts.size == $test_data.size, msg

    msg = 'Get all available drafts'
    client.test_data = nil
    client.limit     = nil
    assert_equal client.d_size, client.get_posts.size
    # assert client.get_posts.size == client.d_size, msg
  end

  def test_drafts_to_queue
    draft_data = $test_data.dup
    expected   = draft_data.size
    moved      = expected - 1
    options = { key_text: 'test_tag', test_data: draft_data,
                mute: true, keep_tree: true }

    msg = 'One draft should not pass key_text'
    assert_equal moved, $client.drafts_to_queue(options).first, msg
  end
end
