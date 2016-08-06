module DK
  # Posts
  DRAFT   = 'draft'.freeze
  QUEUE   = 'queue'.freeze
  PUBLISH = 'published'.freeze
  VALID_STATE = [DRAFT, QUEUE, PUBLISH].freeze

  # Config
  CONFIG_FILENAME = '.dkconfig'.freeze
  VALID_KEYS = %w(consumer_key consumer_secret oauth_token oauth_token_secret).freeze

  # Credit Tag
  CREDIT_TAG = 'tumblr-draftking'.freeze
end
