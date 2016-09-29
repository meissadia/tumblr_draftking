module DK
  # Instance Configuration Methods
  class Config
    # Walk user through setup process
    def self.setup
      config = OpenStruct.new
      config.user_commands = []
      config.api_keys = {}

      setup_display_instructions
      account, as_default = setup_input_config_info(config)
      setup_input_keys(config)

      # Save credentials
      save_file(config: config) if as_default.downcase.include?('y')
      save_file(config: config, account: account)
    end

    # Setup instructions
    def self.setup_display_instructions
      puts "\n * Instructions *"
      puts '1. Register a new application for your Tumblr account at https://www.tumblr.com/oauth/apps'
      puts '2. Once complete, browse to https://api.tumblr.com/console/calls/user/info'
      puts '     to get your API keys.'
    end

    # Account input dialog
    def self.setup_input_config_info(config)
      puts "\n * Configuration Settings *"
      print 'Enter configuration name (account name): '
      account = get_input
      config.config_name = account

      print 'Use this as your default config? (y/N): '
      defconfig = get_input.downcase

      [account, defconfig]
    end

    # API Key input dialog
    def self.setup_input_keys(config)
      puts "\n * API Key Input *"
      print 'Enter consumer key: '
      config.api_keys['consumer_key'] = get_input

      print 'Enter consumer secret: '
      config.api_keys['consumer_secret'] = get_input

      print 'Enter oath token: '
      config.api_keys['oauth_token'] = get_input

      print 'Enter oath token secret: '
      config.api_keys['oauth_token_secret'] = get_input
    end
  end
end
