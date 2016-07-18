require_relative 'test_helper'

class TestCLI < Minitest::Test
  def test_process_opts
    cli_opts = %w(test_command -l 20 -c caption -f filter -k false
                  -b tbn -S drafts -s -a -strip -m --source q)
    command, opts = DK::Helper.process_opts(cli_opts)
    assert_equal 'test_command',    command
    assert_equal 20,                opts[:limit]
    assert_equal 'caption',         opts[:comment]
    assert_equal 'filter',          opts[:filter]
    assert_equal false,             opts[:keep_tree]
    assert_equal 'tbn.tumblr.com',  opts[:blog_url]
    assert_equal 'drafts',          opts[:state]
    assert_equal true,              opts[:simulate]
    assert_equal nil,               opts[:all]
    assert_equal nil,               opts[:strip]
    assert_equal true,              opts[:mute]
    assert_equal :queue,            opts[:source]
  end

  def test_check_opts_value
    val = DK::Helper.check_opts_value('-f', '-f2') rescue 'recovered'
    assert 'recovered' == val
  end

  def test_comment_cli
    opts = { comment: '~ MD ~', keep_tree: false, simulate: true, blog_url: 'ugly-test-blog.tumblr.com' }
    dk = connect_to_client
    assert_equal 4, dk.all_posts(blog_url: opts[:blog_url],
                                 source:   opts.fetch(:source, :draft)).size
    assert_equal 3, dk.comment_posts(opts)
  end
end
