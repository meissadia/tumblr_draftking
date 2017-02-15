# Helpers
require_relative 'cli/cli_helpers'
require_relative 'cli/cli_options'

# More complex CLI Commands
require_relative 'cli/commands/accounts'
require_relative 'cli/commands/autoposter'
require_relative 'cli/commands/blogs'
require_relative 'cli/commands/comment'
require_relative 'cli/commands/console'
require_relative 'cli/commands/movedrafts'
require_relative 'cli/commands/strip'
require_relative 'cli/commands/status'
require_relative 'cli/commands/tag'

# Stored User Commands
require_relative 'cli/commands/user_command'

module DK
  # Command Line Interface
  class CLI < Thor
    include DK::CliHelpers

    desc 'setup', 'Configure and save API keys.'
    def setup
      DK::Config.setup
    end

    desc 'version, -v', 'Display version.'
    option :simulate, type: :boolean, aliases: :s, desc: Options.op_strings[:simulate]
    def version
      vstr = "tumblr_draftking #{DK::VERSION}"
      puts vstr unless options[:simulate]
      vstr
    end
    map '-v' => :version

    desc 'update, check_for_updates', 'Check if DK update is available'
    def check_for_updates
      versions = open('https://rubygems.org/api/v1/versions/tumblr_draftking.json').read
      latest   = JSON.parse(versions, object_class: OpenStruct).first.number
      puts "\n* UPDATE *\n\tDraftKing for Tumblr v#{latest} now available!\n\n" if latest != DK::VERSION
    end
    map 'update' => :check_for_updates

    # Try to execute unrecognized command as User Command
    def method_missing(method, *_args)
      name, attribs = DK::Config.new.user_commands.select { |k, _v| k == method.to_s }.first
      puts "Command '#{method}' not found." && return unless name && attribs
      attribs[:name] = name
      DK::UserCommand.new(attribs).exec!
    end

    # Figure out how to show a submenu of custom commands
    desc 'custom', 'List available User Commands'
    def custom
      title    = 'User Commands'
      commands = DK::Config.new.config.user_commands.map { |n, d| UserCommand.new d.merge(name: n) }
      headers  = %w(name command description config_name)
      Reporter.new(title: title, objects: commands, fields: headers).show
    end
  end
end
