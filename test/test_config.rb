require_relative './test_helper'

class TestConfig < Minitest::Test
  # Validate import of API Keys
  def test_keys
    # API Keys from file (~/.dkconfig2)
    expected = %w(consumer_key consumer_secret oauth_token oauth_token_secret)
    k = api_keys_for_test
    assert_equal expected, k.keys
  end
end
