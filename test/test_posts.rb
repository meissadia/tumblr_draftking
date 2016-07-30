require_relative 'test_helper'

class TestPosts < Minitest::Test
  @@dk = $client

  def test_post_passes_filter
    assert_equal false, DK::Post.new(post_no_comments).passes_filter?(filter: 'test'),   'Filter 1'
    assert_equal true,  DK::Post.new(post_with_comments).passes_filter?(filter: 'test'), 'Filter 2'
    assert_equal false, DK::Post.new(post_with_comments).passes_filter?(filter: 'bc'),   'Filter 3'
  end

  def test_post_change_state
    post = DK::Post.new(post_no_comments)
    assert_equal true, post.change_state(state: DK::QUEUE), 'Valid state'
    assert_equal DK::QUEUE, post.state
  end

  def test_post_add_comment
    # Test Post Tagging - Single
    nc   = DK::Post.new(post_no_comments).replace_comment(comment: 'test')
    wc   = DK::Post.new(post_with_comments).replace_comment(comment: 'test')
    skip = DK::Post.new(post_with_comments).replace_comment(comment: 'skip')

    assert_equal true,  nc,   'post_add_comment no comment'
    assert_equal false, wc,   'post_add_comment already commented'
    assert_equal true,  skip, 'post_add_comment skip comment'
  end

  def test_save_live_post
    assert_equal $test_blog, @@dk.blog_name
    @@dk.client.reblog @@dk.blog_name, id: 148_197_574_140, reblog_key: 'otmSvZBs', state: 'draft' unless @@dk.d_size > 0
    live_post = @@dk.some_posts(limit: 1).first
    assert_equal 1, DK::Post.new(live_post).save(client: @@dk.client)
  end

  def test_delete_live_post
    @@dk.client.reblog @@dk.blog_name, id: 148_197_574_140, reblog_key: 'otmSvZBs'
    assert_equal $test_blog, @@dk.blog_name
    live_post = @@dk.client.posts(@@dk.blog_url, limit: 1)['posts'].first
    assert_equal 1, DK::Post.new(live_post).delete(client: @@dk.client)
  end

  def test_generate_tags
    assert_equal $test_blog, @@dk.blog_name
    tags = DK::Post.new(post_with_comments).generate_tags
    assert_equal 'test comment', tags

    tags = DK::Post.new(post_with_comments).generate_tags(keep_tags: true)
    assert_equal 'test comment,existing,tags', tags

    add_tags = 'added tags,bonus tag'
    tags = DK::Post.new(post_with_comments).generate_tags(keep_tags: true, add_tags: add_tags)
    assert_equal 'test comment,added tags,bonus tag,existing,tags', tags

    assert_equal 'tags', DK::Post.new(post_no_comments).generate_tags(keep_tags: true, exclude: 'existing')
  end

  def test_getposts_drafts
    assert @@dk.some_posts(limit: 1).size == 1
    assert @@dk.some_posts(limit: 2).size <= 2
    assert_equal @@dk.d_size, @@dk.all_posts.size
  end

  def test_getposts_queue
    assert @@dk.some_posts(limit: 1, source: :queue).size <= 1
    assert @@dk.some_posts(limit: 2, source: :queue).size <= 2
    assert_equal @@dk.q_size, @@dk.all_posts(source: :queue).size
  end
end
