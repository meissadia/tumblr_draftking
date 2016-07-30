require_relative './test_helper'

class TestConfig < Minitest::Test
  # Validate import of API Keys
  def test_keys
    # API Keys from file (~/.dkconfig2)
    expected = %w(consumer_key consumer_secret oauth_token oauth_token_secret)
    k = TestData.keys
    assert_equal expected, k.keys
  end

  def test_command_valid
    assert_equal false, DK::Config.command_valid?('jump')
    assert_equal true,  DK::Config.command_valid?('strip')
  end
end
