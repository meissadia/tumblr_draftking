require_relative 'test_helper'

class TestClient < Minitest::Test
  def test_version
    assert /^tumblr_draftking\s(\d*.)*\d$/.match(DK::CLI.version)
  end

  # Validate client connection
  def test_creation
    comment  = 'test_comment'
    blog     = 'ugly-test-blog'
    keys     = TestData.keys

    opts = { keys: keys, blog_name: blog, simulate: true, comment: comment }
    dk   = DK::Client.new(opts)

    refute_nil   dk.client,           'Connection not established!'
    refute_nil   dk.q_size,           'Read Queue size failed!'
    refute_nil   dk.d_size,           'Read Draft size failed!'
    assert_equal comment, dk.comment, 'Default comment failed!'
    assert_equal dk.blog_name, blog,  'Blog Name failed!'
    assert_equal dk.blog_url,  blog + '.tumblr.com', 'Blog URL failed!'

    opts = { keys: keys, blog_name: nil, simulate: true, comment: comment }
    dk   = DK::Client.new(opts)

    refute_nil   dk.client,           'Connection not established!'
    refute_nil   dk.q_size,           'Default Queue size failed!'
    refute_nil   dk.d_size,           'Default Draft size failed!'
    assert dk.blog_name != blog,      'Default Blog Name failed!'
  end
end
