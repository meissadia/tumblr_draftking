require_relative 'test_helper'

class TestDrafts < Minitest::Test
  def test_comment_posts_all
    draft_data = $test_data.dup
    expected   = draft_data.size
    options    = { comment: 'different comment', test_data: draft_data,
                   mute: true }
    tagged     = $client.comment_posts(options)
    assert_equal expected, tagged, 'Add comment to all drafts'
  end

  def test_comment_posts_limit
    draft_data = $test_data.dup
    expected   = 20
    # test_show_progress
    options = { comment: '001 comment', test_data: draft_data, limit: expected }
    tagged  = $client.comment_posts(options)
    assert_equal expected, tagged, 'Comment some drafts'
  end

  def test_strip_comments
    opts = { test_data: $test_data.dup, mute: true }
    msg  = 'All drafts have been modified'
    assert_equal 93, $client.strip_old_comments(opts), msg
  end

  def test_getdrafts
    # Valide Draft Numbers
    $client.act_on_blog(name: $client.blog_name)
    assert $client.d_size >= 0, 'Draft size has been initialized'

    opts = { limit: 12 }
    assert $client.getposts(opts).size <= 12, 'Get a specific number of drafts'

    opts = { test_data: $test_data }
    msg  = 'Use test data when present'
    assert $client.getposts(opts).size == $test_data.size, msg

    msg = 'Get all available drafts'
    assert $client.getposts({}).size == $client.d_size, msg
  end

  def test_drafts_to_queue
    draft_data = $test_data.dup
    expected   = draft_data.size
    moved      = expected - 1
    options = { filter: 'test_tag', test_data: draft_data,
                mute: true,         keep_tree: true }

    msg = 'One draft should not pass filter'
    assert_equal moved, $client.drafts_to_queue(options), msg
  end
end
