require_relative 'test_helper'

class TestClient < Minitest::Test
  # Validate client connection
  def test_creation_success
    opts = { keys: api_keys_for_test, blog_name: $test_blog,
             simulate: true, comment: $test_comment }

    dk   = DK::Client.new(opts)
    refute_nil   dk.client, 'Connection not established!'
    refute_nil   dk.q_size, 'Read Queue size failed!'
    refute_nil   dk.d_size, 'Read Draft size failed!'
    assert_equal $test_comment, dk.comment,   'Default comment failed!'
    assert_equal $test_blog,    dk.blog_name, 'Blog Name failed!'
    assert_equal dk.blog_url, $test_blog + '.tumblr.com', 'Blog URL failed!'
  end

  def test_creation_failure
    opts = { keys: api_keys_for_test, blog_name: nil, simulate: true }
    dk   = DK::Client.new(opts)
    refute_nil  dk.client,  'Connection not established!'
    refute_nil  dk.q_size,  'Default Queue size failed!'
    refute_nil  dk.d_size,  'Default Draft size failed!'
    assert dk.blog_name != $test_blog, 'Default Blog Name failed!'
  end
end
