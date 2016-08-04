module DK
  class CLI < Thor
    desc 'accounts', 'Manage configured accounts'
    option :delete, type: :boolean, aliases: :d, desc: 'Delete account configuration'
    option :switch, type: :boolean, aliases: :s, desc: 'Switch default account configuration'
    def accounts
      files = DK::Config.available_configs
      show_accounts(files)
      return if options.empty? # Empty = no action to take
      puts accounts_input_dialogue(options)
      choice = DK::Config.get_input
      return if /[^0-9]/ =~ choice
      file = files[choice.to_i]
      accounts_action(file, options)
    end

    private

    # Show available accounts
    # @param account_list [[String]] List of configuration files
    def show_accounts(account_list)
      puts "\n* ---- Accounts ---- *"
      account_list.each_with_index do |config, idx|
        (puts "    #{idx}. (Default)"; next) if config == DK::CONFIG_FILENAME
        puts "    #{idx}. #{accounts_extract_name(config)}" # Only show account name
      end
      puts
    end

    def accounts_input_dialogue(options)
      return "\nEnter # to use as DEFAULT ('x' to exit): " if options[:switch]
      return "\nEnter # to DELETE ('x' to exit): "         if options[:delete]
    end

    def accounts_action(filename, options)
      msg = accounts_delete(filename) if options[:delete]
      msg = accounts_switch(filename) if options[:switch]
      puts msg + "\n\n"
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
