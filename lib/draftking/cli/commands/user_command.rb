module DK
  # User Defined Command
  class UserCommand
    REQUIRED_FIELDS = %w(command).freeze
    def initialize(opts)
      opts.each_pair do |k, v|
        singleton_class.class_eval { attr_accessor k.to_s }
        send("#{k}=", v)
      end
      check_required_fields
    end

    # Replace current process with execution of @command
    def exec!
      # Prefix test commands
      command = prefix_command('bin/', Dir.pwd.include?('tumblr_draftking'))
      command = add_config_name(command)
      puts "User Command: #{command}"
      exec(command)
    end

    private

    def prefix_command(prfx, i_should = true)
      # Add prefix to commands, but only once
      return (prfx + @command).gsub(/^(#{prfx})+/, '\1') if i_should
      @command
    end

    def add_config_name(command)
      cfig = @config_name ? " --config #{@config_name}" : nil
      return command + cfig unless command.include?(cfig)
      command
    end

    def check_required_fields
      REQUIRED_FIELDS.all? do |x|
        # Field is accessible and populated
        next if instance_variables.include?("@#{x}".to_sym) && !send(x.to_s).nil?
        raise ArgumentError, "#{x}: required!"
      end
    end
  end
end
