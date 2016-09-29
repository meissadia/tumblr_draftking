if ENV['CI_FLAG']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
else
  require 'simplecov'
  SimpleCov.start
end

require 'minitest/autorun'
require_relative '../lib/tumblr_draftking'

def config_default_filename
  File.join(ENV['HOME'], '.dkconfig2')
end

def api_keys_for_test
  DK::Config.load_api_keys(file: config_default_filename)
end

def connect_to_client(blog: nil, comment: nil)
  blog    ||= $test_blog
  comment ||= $test_comment
  DK::Client.new(keys: api_keys_for_test, blog_name: blog, comment: comment, simulate: true)
end

def deployment?
  ENV['CI_FLAG']
end

def load_draft_data(filename = 'test/all_drafts.json')
  JSON.parse(File.read(filename))
end

def post_no_comments
  {
    'blog_name' => 'test_blog_name',
    'reblog_key' => '2fj2kjf2fj',
    'id' => 14_745_745,
    'type' => 'photo',
    'state' => 'draft',
    'tags' => %w(existing tags),
    'summary' => '',
    'caption' => '',
    'reblog' => {
      'tree_html' => '<p>strip this text</p>',
      'comment' => ''
    }
  }
end

def post_with_comments
  {
    'blog_name' => 'test_blog_name',
    'reblog_key' => '2fj2kjf2fj',
    'id' => 14_745_745,
    'type' => 'photo',
    'state' => 'draft',
    'tags' => %w(existing tags),
    'summary' => 'test | more test , last text',
    'caption' => '<p>test | more test , last text</p>',
    'reblog' => {
      'tree_html' => '<p>strip this text</p>',
      'comment' => '<p>test comment</p>'
    }
  }
end

$test_tag     = 'test_tag'
$test_blog    = 'ugly-test-blog'
$test_comment = 'test_comment'
$client       = connect_to_client
$test_data    = load_draft_data
