require_relative 'config/config_setup'
require 'ostruct'

module DK
  class Adapter
    def initialize(data)
      @data = data
    end

    def adapt
      # return adapted data
    end
  end

  class ConfigAdapter < Adapter
    def initialize(data, file = nil)
      super(data)
      @file = file
    end

    def adapt
      if @data.keys.include?('consumer_key')
        r = OpenStruct.new
        r.user_commands = []
        r.api_keys = @data
        puts "Config #{@file} needs to be updated!"
        print 'Enter a name for this configuration: '
        r.config_name = DK::Config.get_input
        Config.save_file(config: r, filename: @file)
      end
      r || @data
    end
  end

  # Instance Configuration Methods
  class Config
    attr_accessor :config, :filename
    def initialize(opts = {})
      @filename = opts[:file]
      @config   = OpenStruct.new(load_config(@filename))
      @def_conf = self.class.home_path_file(DK::CONFIG_FILENAME)
    end

    # Easily access config opts
    def method_missing(method, *_args)
      @config.send(method) unless @config.nil?
    end

    # Load config from passed or default file
    def load_config(file = nil)
      file ||= self.class.home_path_file(DK::CONFIG_FILENAME)
      return nil unless File.exist?(file.to_s)
      ConfigAdapter.new(load_yaml_file(file), file).adapt
    end

    # Contents of YAML file
    def load_yaml_file(file)
      YAML.load_file(file)
    rescue
      YAML.parse_file(file)
    end

    # Is this configuration the current default?
    def is_default?
      @filename == @def_conf
    end

    # Check that all 4 keys have been provided
    # @param api_keys [Hash] API Keys
    def self.validate_keys(api_keys)
      return nil if api_keys.nil?
      return nil unless api_keys.respond_to?(:keys)
      return nil unless api_keys.keys.all? { |k| VALID_KEYS.include?(k.to_s) }
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
      exec('bin/dk setup') unless File.exist?(file.to_s)
      validate_keys(DK::Config.new(file: file).api_keys)
    end

    # Save Configuration to File
    def self.save_file(config:, account: '', mute: false, filename: nil)
      account = '.' + account unless account.empty?
      path = filename || home_path_file(account + DK::CONFIG_FILENAME)
      File.open(path, 'w') { |f| f.write YAML.dump config.to_h }
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
      save_file config: DK::Config.new(file: home_path_file(file)).config, mute: mute
    end

    # Delete a configuration file from the home directory
    def self.delete_config(file)
      return false unless File.exist?(home_path_file(file))
      File.delete(home_path_file(file))
      true
    rescue
      false
    end
  end
end

DK::Config.available_configs
