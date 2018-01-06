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
    cli.accounts # Choose your testing configuration to restore it for the remaining tests
  end

  def test_comment
    comment = '~MD~'
    assert  1 <= @@cli.comment(comment).first, 'Add comment to at least 1 live post'
  end

  def test_tag
    cli = @@cli.dup
    cli.options = { simulate: true, blog: $test_blog, mute: true, credit: true }
    assert_equal $client.d_size, cli.tag.first, 'Tag fail'
  end

  def test_strip
    assert_equal $client.d_size, @@cli.strip.first, 'Strip fail'
  end

  def test_move_drafts
    assert_equal $client.d_size, @@cli.movedrafts.first, 'Move Drafts'
  end

  def test_blogs
    result = @@cli.blogs
  end

  def test_status
    strings = @@cli.status('ugly-test-blog')
  end

  def test_version
    pattern = /tumblr_draftking\s(\d+\.?){3}/
    cli = @@cli.dup
    cli.options = { simulate: true }
    refute_nil pattern.match(cli.version)
  end

  def test_options
    ops  = [:add_tags, :blog, :comment, :key_text, :keep_comments, :keep_tags, :greedy, :link]
    ops += [:limit, :mute, :publish, :simulate, :source, :state, :credit, :tags, :config, :file]
    assert DK::Options.op_strings.keys.all? { |op| ops.include?(op) }
    pattern = /^Comma separated string of tags to add.\n\n/
    assert pattern.match DK::Options.descriptions(ops)
  end
end
