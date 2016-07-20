if ENV['CI_FLAG']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
else
  require 'simplecov'
  SimpleCov.start
end

require 'minitest/autorun'
require_relative '../lib/tumblr_draftking'

def connect_to_client(blog = nil, tag = 'test_tag')
  DK::Client.new(blog_name: blog, comment: tag, simulate: true)
end

def load_draft_data(filename = 'test/all_drafts.json')
  JSON.parse(File.read(filename))
end

def post_no_comments
  {
    'blog_name' => 'test_blog_name',
    'id' => 14_745_745,
    'type' => 'photo',
    'state' => 'draft',
    'tags' => [],
    'summary' => '',
    'caption' => ''
  }
end

def post_with_comments
  {
    'blog_name' => 'test_blog_name',
    'id' => 14_745_745,
    'type' => 'photo',
    'state' => 'draft',
    'tags' => [],
    'summary' => 'test | more test , last text',
    'caption' => '<p>test | more test , last text</p>'
  }
end
