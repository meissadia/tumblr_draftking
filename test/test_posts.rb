require_relative 'test_helper'

class TestPosts < Minitest::Test
  @@dk = connect_to_client # Make one connection to reduce overhead

  def test_post_passes_filter
    assert_equal false, @@dk.post_passes_filter?(post_no_comments,   filter: 'test'), 'Filter 1'
    assert_equal true,  @@dk.post_passes_filter?(post_with_comments, filter: 'test'), 'Filter 2'
    assert_equal false, @@dk.post_passes_filter?(post_with_comments, filter: 'bc'),   'Filter 3'
  end

  def test_post_change_state
    post = post_no_comments
    assert_equal true, @@dk.post_change_state(post, state: DK::QUEUE), 'Valid state'
    assert_equal DK::QUEUE, post['state']
  end

  def test_post_add_comment
    # Test Post Tagging - Single
    nc   = @@dk.post_add_comment(post_no_comments,   comment: 'test')
    wc   = @@dk.post_add_comment(post_with_comments, comment: 'test')
    skip = @@dk.post_add_comment(post_with_comments, comment: 'skip')

    assert_equal true, nc,    'post_add_comment no comment'
    assert_equal false, wc,   'post_add_comment already commented'
    assert_equal true, skip,  'post_add_comment skip comment'
  end

  def test_getposts_drafts
    assert_equal 1, @@dk.some_posts(limit: 1).size
    assert_equal 2, @@dk.some_posts(limit: 2).size
    assert_equal @@dk.d_size, @@dk.all_posts.size
  end

  def test_getposts_queue
    assert_equal 1, @@dk.some_posts(limit: 1, source: :queue).size
    assert_equal 2, @@dk.some_posts(limit: 2, source: :queue).size
    assert_equal @@dk.q_size, @@dk.all_posts(source: :queue).size
  end
end
