require_relative './test_helper'

class TestConfig < Minitest::Test
  # Validate import of API Keys
  def test_keys
    # API Keys from file (~/.dkconfig2)
    expected = %w(consumer_key consumer_secret oauth_token oauth_token_secret)
    k = api_keys_for_test
    assert_equal expected, DK::Config.validate_keys(k).keys
  end

  def test_home_path_file
    expected = "#{ENV['HOME']}/.dkconfig"
    assert_equal expected, DK::Config.home_path_file('.dkconfig'), 'Bad filename'
  end

  def test_available_configs
    available = DK::Config.available_configs
    ['.dkconfig', '.spark.dkconfig', '.utb.dkconfig'].each do |expected|
      assert available.include?(expected), "#{expected} config not found!"
    end
  end

  def test_configured
    assert DK::Config.configured?
  end

  def test_save_file_delete_config
    assert DK::Config.save_file(config: api_keys_for_test, account: 'test_account', mute: true)
    assert DK::Config.delete_config('.test_account.dkconfig')
    refute DK::Config.delete_config('.test_account.dkconfig')
  end

  def test_switch_default
    # Setup
    assert DK::Config.save_file(config: api_keys_for_test, account: 'test_account', mute: true)

    # Exercise
    assert DK::Config.switch_default_config('.test_account.dkconfig', true)
    assert DK::Config.switch_default_config(DK::CONFIG_FILENAME) # Should have no effect

    # Validate
    file = DK::Config.home_path_file('.test_account.dkconfig')
    assert_equal api_keys_for_test, DK::Config.load_api_keys(file: file)

    # Teardown
    assert DK::Config.delete_config('.test_account.dkconfig')
    assert DK::Config.switch_default_config('.dkconfig2', true)
    file = DK::Config.home_path_file('.dkconfig2')
    assert_equal DK::Config.load_api_keys(file: file), DK::Config.load_api_keys
  end
end
