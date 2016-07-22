module DK
  class Config
    # Check that all 4 keys have been provided
    def self.validate_keys(api_keys)
      return nil if api_keys.nil?
      return nil unless api_keys.respond_to?(:keys)
      return nil unless api_keys.keys.sort == VALID_KEYS
      return nil if api_keys.values.include?(nil)
      api_keys
    end

    # Configure tumblr gem
    def self.configure_tumblr_gem(file: nil, keys: nil)
      api_keys = keys || load_api_keys(file: file)
      return false if api_keys.nil?
      Tumblr.configure do |config|
        api_keys.each do |key, value|
          config.send(:"#{key}=", value)
        end
      end
      true
    end

    # Read API Keys from file
    def self.load_api_keys(file: nil)
      file ||= File.join(ENV['HOME'], DK::CONFIG_FILENAME)
      return nil unless File.exist?(file.to_s)
      keys = YAML.load_file(file) rescue YAML.parse_file(file)
      validate_keys(keys)
    end

    # Save API Keys to file
    def self.setup
      ARGV.clear
      config = {}
      path   = File.join ENV['HOME'], DK::CONFIG_FILENAME
      puts
      puts 'Register a new application for you Tumblr account at https://www.tumblr.com/oauth/apps'
      puts 'Once complete, browse to https://api.tumblr.com/console/calls/user/info'
      puts
      print 'Enter consumer key: '
      config['consumer_key'] = gets.chomp.gsub(/[\'\']/, '')

      print 'Enter consumer secret: '
      config['consumer_secret'] = gets.chomp.gsub(/[\'\']/, '')

      print 'Enter oath token: '
      config['oauth_token'] = gets.chomp.gsub(/[\'\']/, '')

      print 'Enter oath token secret: '
      config['oauth_token_secret'] = gets.chomp.gsub(/[\'\']/, '')

      # Save credentials
      File.open(path, 'w') do |f|
        f.write YAML.dump config
      end

      puts "\nConfiguration saved to #{path}"
      puts
    end

    # Check for configuration file
    def self.configured?
      File.exist?(File.join(ENV['HOME'], DK::CONFIG_FILENAME))
    end

    def self.command_valid?(command)
      %w(blogs comment c_and_m move_drafts status strip).include?(command)
    end
  end
end
