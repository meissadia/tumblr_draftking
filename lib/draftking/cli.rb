# Helpers
require_relative 'cli/cli_helpers'
require_relative 'cli/cli_options'

# More complex CLI Commands
require_relative 'cli/commands/accounts'
require_relative 'cli/commands/blogs'
require_relative 'cli/commands/comment'
require_relative 'cli/commands/movedrafts'
require_relative 'cli/commands/strip'
require_relative 'cli/commands/status'
require_relative 'cli/commands/tag'

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
  end
end
