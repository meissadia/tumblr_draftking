module DK
  # Posts
  DRAFT   = 'draft'.freeze
  QUEUE   = 'queue'.freeze
  PUBLISH = 'published'.freeze
  VALID_STATE = [DRAFT, QUEUE, PUBLISH].freeze

  # Post
  HTML_TAG_PATTERN = /<[\/]?[\w\d]+\s?(?:[\w\d\-]+=[^>]*>\s?)*>?/

  # Config
  CONFIG_FILENAME = '.dkconfig'.freeze
  VALID_KEYS = %w(consumer_key consumer_secret oauth_token oauth_token_secret).freeze

  # Credit Tag
  CREDIT_TAG = 'DraftKing for Tumblr'.freeze

  # Scaling
  MAX_THREADS = 3

  # PostReporter
  REPORT_TITLE  = 'Post Report'.freeze
  REPORT_FIELDS = %w(id state comment tags).freeze
  REPORT_SIM    = ' (SIMULATION)'.freeze
end
