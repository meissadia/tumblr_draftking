require_relative 'test_helper'

class TestPosts < Minitest::Test
  @@dk = $client

  def test_post_to_s
    pattern = /(\w*\s=\s[\w\d\s]*\n)*/
    refute_nil pattern.match(DK::Post.new(post_with_comments).to_s)
  end

  def test_post_passes_key_text
    assert_equal false, DK::Post.new(post_no_comments).has_key_text?('test'),   'key_text 1'
    assert_equal true,  DK::Post.new(post_with_comments).has_key_text?('test'), 'key_text 2'
    assert_equal false, DK::Post.new(post_with_comments).has_key_text?('bc'),   'key_text 3'
  end

  def test_post_change_state
    post = DK::Post.new(post_no_comments)
    assert_equal true, post.change_state(DK::QUEUE), 'Valid state'
    assert_equal DK::QUEUE, post.state
  end

  def test_post_add_comment
    # Test Post Tagging - Single
    nc   = DK::Post.new(post_no_comments).replace_comment_with('test')
    wc   = DK::Post.new(post_with_comments).replace_comment_with('test')
    skip = DK::Post.new(post_with_comments).replace_comment_with('skip')

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
    post = DK::Post.new(live_post)
    post.changed = true
    assert_equal 1, post.save(client: dk.client)
  end

  def test_delete_live_post
    @@dk.client.reblog @@dk.blog_name, id: 148_197_574_140, reblog_key: 'otmSvZBs'
    assert_equal $test_blog, @@dk.blog_name
    live_post = @@dk.client.posts(@@dk.blog_url, limit: 1)['posts'].first
    assert_equal 1, DK::Post.new(live_post).delete(client: @@dk.client)
  end

  def test_generate_tags
    assert_equal $test_blog, @@dk.blog_name
    tags = DK::Post.new(post_with_comments).generate_tags(credit: true)
    assert_equal 'test,more test,last text,DraftKing for Tumblr', tags.join(',')

    tags = DK::Post.new(post_with_comments).generate_tags(keep_tags: true, credit: false)
    assert_equal 'test,more test,last text,existing,tags', tags.join(',')

    add_tags = 'added tags,bonus tag'
    tags = DK::Post.new(post_with_comments).generate_tags(keep_tags: true, add_tags: add_tags)
    assert_equal 'test,more test,last text,added tags,bonus tag,existing,tags', tags.join(',')

    assert_equal 'tags', DK::Post.new(post_no_comments).generate_tags(keep_tags: true, exclude: 'existing', credit: false).join(',')
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

  def test_limited_posts
    skip if @@dk.d_size < 52
    dk = @@dk.dup
    dk.limit = 52
    dk.all_posts.take(dk.limit) == dk.limited_posts
  end

  def test_clear_tags
    post = DK::Post.new(post_with_comments)
    refute post.tags.empty?
    post.clear_tags
    assert post.tags.empty?
  end

  def test_html_comments
    post = DK::Post.new(post_no_comments)
    post.comment = "<center id='crazy'><i>M/D</i></center>"
    post.generate_tags(exclude: 'M,D')
    assert_equal [], post.tags
  end
end
