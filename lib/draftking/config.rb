module DK
  class DkConfig
    # Configure Tumblr gem using
    def self.configure_tumblr_gem(file = nil)
      keys = file.nil? ? DkConfig.load_api_keys : DkConfig.load_api_keys(file)
      Tumblr.configure do |config|
        keys.each do |key, value|
          config.send(:"#{key}=", value)
        end
      end
    end

    # Read API Keys from file
    def self.load_api_keys(file = '.dkconfig')
      file = File.join ENV['HOME'], '.dkconfig'
      YAML.load_file(file) rescue YAML.parse_file(file)
    end

    # Save API Keys to file
    def self.setup
      ARGV.clear
      config = {}
      path   = File.join ENV['HOME'], '.dkconfig'
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

    # Check for .dkconfig file
    def self.configured?
      File.exist?(File.join(ENV['HOME'], '.dkconfig'))
    end

    def self.command_valid?(command)
      %w(blogs comment c_and_m move_drafts status strip).include?(command)
    end
  end
end
