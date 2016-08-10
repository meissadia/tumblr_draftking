require_relative 'test_helper'

class TestPosts < Minitest::Test
  @@dk = $client

  def test_post_to_s
    pattern = /(\w*\s=\s[\w\d\s]*\n)*/
    refute_nil pattern.match(DK::Post.new(post_with_comments).to_s)
  end

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
    dk = @@dk.dup
    assert_equal $test_blog, dk.blog_name
    dk.client.reblog dk.blog_name, id: 148_197_574_140, reblog_key: 'otmSvZBs', state: 'draft' unless dk.d_size > 0
    dk.limit = 1
    live_post = dk.some_posts.first
    assert_equal 1, DK::Post.new(live_post).save(client: dk.client)
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
    assert_equal 'test comment,tumblr-draftking', tags

    tags = DK::Post.new(post_with_comments).generate_tags(keep_tags: true, credit: false)
    assert_equal 'test comment,existing,tags', tags

    add_tags = 'added tags,bonus tag'
    tags = DK::Post.new(post_with_comments).generate_tags(keep_tags: true, add_tags: add_tags)
    assert_equal 'test comment,added tags,bonus tag,existing,tags,tumblr-draftking', tags

    assert_equal 'tags', DK::Post.new(post_no_comments).generate_tags(keep_tags: true, exclude: 'existing', credit: false)
  end

  def test_getposts_drafts
    dk = @@dk.dup
    dk.limit = 1
    assert dk.some_posts.size == 1
    dk.limit = 2
    assert dk.some_posts.size <= 2
    assert_equal dk.d_size, dk.all_posts.size
  end

  def test_getposts_queue
    dk = @@dk.dup
    dk.limit  = 1
    dk.source = :queue
    assert dk.some_posts.size <= 1
    dk.limit = 2
    assert dk.some_posts.size <= 2
    assert_equal dk.q_size, dk.all_posts.size
  end

  def test_reblog
    dk = @@dk.dup
    dk.limit = 1
    post = DK::Post.new dk.some_posts.first
    assert post.reblog(client: dk.client, simulate: true)
    assert post.reblog(client: dk.client)
  end
end
