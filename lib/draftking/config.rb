require_relative 'config/config_setup'

module DK
  # Instance Configuration Methods
  class Config
    # Check that all 4 keys have been provided
    # @param api_keys [Hash] API Keys
    def self.validate_keys(api_keys)
      return nil if api_keys.nil?
      return nil unless api_keys.respond_to?(:keys)
      return nil unless VALID_KEYS.all? { |k| api_keys.keys.include?(k) }
      return nil if api_keys.values.include?(nil)
      api_keys
    end

    # Configure Tumblr gem
    # @param file [String] JSON File with API Keys
    # @param keys [Hash] Hash with API Keys
    def self.configure_tumblr_gem(file: nil, keys: nil)
      api_keys = keys || load_api_keys(file: file) || load_api_keys(file: home_path_file(available_configs.first))
      return false if api_keys.nil?
      Tumblr.configure do |config|
        api_keys.each do |key, value|
          config.send(:"#{key}=", value)
        end
      end
      true
    end

    # Read API Keys from file
    # @param file [String] JSON File with API Keys
    def self.load_api_keys(file: nil)
      file ||= home_path_file(DK::CONFIG_FILENAME)
      return nil unless File.exist?(file.to_s)
      keys = begin
        YAML.load_file(file)
      rescue
        YAML.parse_file(file)
      end
      validate_keys(keys)
    end

    # Save Configuration to File
    def self.save_file(config:, account: '', mute: false)
      account = '.' + account unless account.empty?
      path = home_path_file(account + DK::CONFIG_FILENAME)
      File.open(path, 'w') { |f| f.write YAML.dump config }
      puts "\nConfiguration saved to #{path} #{'(Default)' if account.empty?}" unless mute
      path
    rescue
      false
    end

    # Get input without quotes
    def self.get_input
      ARGV.clear
      gets.chomp.gsub(/[\'\"]/, '')
    end

    # Does default configuration file exists
    def self.configured?
      !available_configs.empty?
    end

    # All .dkconfig files in home directory
    def self.available_configs
      glob = home_path_file('*' + DK::CONFIG_FILENAME)
      Dir.glob(glob, File::FNM_DOTMATCH).map { |f| f.split('/').last }
    end

    # Path to file in home directory
    def self.home_path_file(fname)
      File.join Dir.home, fname
    end

    # Copy API Keys from alternate file to the default configuration file
    def self.switch_default_config(file, mute = false)
      return true if file.eql? DK::CONFIG_FILENAME
      save_file config: load_api_keys(file: home_path_file(file)), mute: mute
    end

    # Delete a configuration file from the home directory
    def self.delete_config(file)
      File.delete(home_path_file(file))
      true
    rescue
      false
    end
  end
end

DK::Config.available_configs
