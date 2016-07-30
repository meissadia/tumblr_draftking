require_relative 'test_helper'

class TestCLI < Minitest::Test
  def test_process_opts
    cli_opts = %w(test_command -l 20 -c caption -f filter -k false
                  -b tbn -S drafts -s -m --source q -kt)
    command, opts = DK::Helper.process_opts(cli_opts)
    assert_equal 'test_command',    command
    assert_equal 20,                opts[:limit]
    assert_equal 'caption',         opts[:comment]
    assert_equal 'filter',          opts[:filter]
    assert_equal false,             opts[:keep_tree]
    assert_equal 'tbn',             opts[:blog_name]
    assert_equal 'drafts',          opts[:state]
    assert_equal true,              opts[:simulate]
    assert_equal true,              opts[:keep_tags]
    assert_equal true,              opts[:mute]
    assert_equal :queue,            opts[:source]
  end

  def test_check_opts_value
    val = DK::Helper.check_opts_value('-f', '-f2') rescue 'recovered'
    assert 'recovered' == val
  end

  def test_comment_cli
    opts = { comment: '~ MD ~', keep_tree: false, simulate: true, blog_name: $test_blog, mute: true }
    assert  0 <= $client.all_posts(blog_url: opts[:blog_url], source: opts.fetch(:source, :draft)).size
    assert  1 <= $client.comment_posts(opts)
  end

  def test_print_list_blog
    string = DK::CLI.print_blog_list(DK::Client.new(simulate: true, keys: api_keys_for_test))
    refute_nil /#-*\s\w*\s-*#(\n\d*.\s\w*)*/.match(string)
  end

  def test_command_valid
    assert_equal false, DK::CLI.command_valid?('jump')
    assert_equal true,  DK::CLI.command_valid?('strip')
  end
end
