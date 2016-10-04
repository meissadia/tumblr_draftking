module DK
  class CLI < Thor
    desc 'accounts', 'Manage configured accounts'
    option :delete, type: :boolean, aliases: :d, desc: 'Delete account configuration'
    option :switch, type: :boolean, aliases: :s, desc: 'Switch default account configuration'
    option :config, type: :string,  desc: Options.op_strings[:config]
    def accounts
      files = DK::Config.available_configs
      show_accounts(files)
      return if options.empty? # Empty = no action to take
      puts accounts_input_dialogue(options)
      opts = process_options(options)
      choice = config_to_num(opts[:config]) || DK::Config.get_input
      return if /[^0-9]/ =~ choice
      file = files[choice.to_i]
      return if file.nil?
      msg = accounts_action(file, opts)
      show_accounts(DK::Config.available_configs, msg)
    end

    private

    # Show available accounts
    # @param account_list [[String]] List of configuration file names
    def show_accounts(account_list, _msg = nil)
      title  = 'Accounts'
      fields = %w(# name default file)
      rows   = []
      account_list.each_with_index do |config, idx|
        file = DK::Config.home_path_file(config)
        conf = DK::Config.new(file: file)
        default = ' (X)' if conf.is_default?
        rows << [idx, conf.config_name, default, file]
      end
      Reporter.new(title: title, rows: rows, headers: fields).show
    end

    def accounts_input_dialogue(options)
      return if options[:config]
      return "\nEnter # to use as DEFAULT ('x' to exit): " if options[:switch]
      return "\nEnter # to DELETE ('x' to exit): "         if options[:delete]
    end

    def accounts_action(filename, options)
      msg = accounts_delete(filename) if options[:delete]
      msg = accounts_switch(filename) if options[:switch]
      puts "#{msg}\n\n" if msg
      msg
    end

    def accounts_extract_name(filename)
      filename.gsub(/(^\.)|(.dkconfig)/, '')
    end

    def accounts_delete(file)
      account = accounts_extract_name(file)
      DK::Config.delete_config(file) ? "Deleted account: #{account}." : "Failed to delete account: #{account}!"
    end

    def accounts_switch(file)
      return 'No change made.' if file == DK::CONFIG_FILENAME
      account = accounts_extract_name(file)
      DK::Config.switch_default_config(file) ? "New default account: #{account}." : 'Unable to change default account!'
    end
  end
end
