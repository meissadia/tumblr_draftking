require_relative './test_helper'

class TestConnection < Minitest::Test
  # Validate import of API Keys
  def test_keys
    k = DK::DkConfig.load_api_keys
    expected = %w(consumer_key consumer_secret oauth_token oauth_token_secret)
    assert_equal expected, k.keys
  end

  # Validate client connection
  def test_creation
    tag  = 'test_tag'
    blog = 'beautifully-test-blog'
    dk   = connect_to_client

    assert     dk.client.info,    'Connection not established!'
    assert     dk.caption == tag, 'Default caption failed!'
    refute_nil dk.q_size,         'Queue size failed!'
    refute_nil dk.d_size,         'Draft size failed!'

    assert dk.blog_url = blog + 'tumblr.com', 'Blog URL failed!'
  end
end
