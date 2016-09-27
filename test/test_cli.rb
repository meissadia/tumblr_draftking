require_relative 'test_helper'

class TestCLI < Minitest::Test
  @@cli = DK::CLI.new [], simulate: true, blog: $test_blog, mute: true, keep_tree: true

  def test_user_interactions
    skip unless deployment?

    # Setup
    file = '.test.dkconfig'
    assert @@cli.setup.include?(file)

    # Accounts
    cli = @@cli.dup
    cli.options = { delete: true }
    cli.accounts # Delete account: test

    cli.options = { switch: true }
    cli.accounts # Choose 0
    cli.accounts # Choose utb
  end

  def test_comment
    comment = '~MD~'
    assert  1 <= @@cli.comment(comment), 'Add comment to at least 1 live post'
  end

  def test_tag
    cli = @@cli.dup
    cli.options = { simulate: true, blog: $test_blog, mute: true, credit: true }
    assert_equal $client.d_size, cli.tag, 'Tag fail'
  end

  def test_strip
    assert_equal $client.d_size, @@cli.strip, 'Strip fail'
  end

  def test_move_drafts
    assert_equal $client.d_size, @@cli.movedrafts, 'Move Drafts'
  end

  def test_blogs
    result = @@cli.blogs
    pattern = /#-*\s\w*\s-*#(\n\d*.\s\w*)*/
    refute_nil pattern.match(result)
  end

  def test_status
    strings = @@cli.status('ugly-test-blog')
    pattern = /(\w*\s\w*:\s\d*\n+)*/
    strings.all? do |string|
      assert string.nil? || pattern.match(string)
    end
  end

  def test_version
    pattern = /tumblr_draftking\s(\d+\.?){3}/
    cli = @@cli.dup
    cli.options = { simulate: true }
    refute_nil pattern.match(cli.version)
  end

  def test_options
    ops  = [:add_tags, :blog, :comment, :key_text, :keep_comments, :keep_tags]
    ops += [:limit, :mute, :publish, :simulate, :source, :state, :credit, :tags]
    assert DK::Options.op_strings.keys.all? { |op| ops.include?(op) }
    pattern = /^Comma separated string of tags to add.\n\n/
    assert pattern.match DK::Options.descriptions(ops)
  end
end
