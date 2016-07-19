module DK
  module CLI
    # Launch IRB with tumblr_draftking loaded
    def launch_console
      require 'irb'
      require 'irb/completion'
      ARGV.clear
      $dk = DK::Client.new simulate: true
      IRB.start
    end

    # Build option hash from command line args
    def process_opts(argv)
      opts = {}
      skip = false
      command = nil
      argv.each_with_index do |arg, idx|
        if skip
          skip = false
          next
        end
        if arg[0].eql?('-')
          case arg
          when '-b', '--blog'
            opts[:blog_url] = get_flag_value(arg, argv, idx) + '.tumblr.com'
            skip = true
          when '-c', '--comment'
            opts[:comment] = get_flag_value(arg, argv, idx)
            skip = true
          when '-f', '--filter'
            opts[:filter] = get_flag_value(arg, argv, idx)
            skip = true
          when '-k', '--keep'
            opts[:keep_tree] = get_flag_value(arg, argv, idx)
            skip = true
          when '-l', '--limit'
            opts[:limit] = get_flag_value(arg, argv, idx).to_i
            opts.delete(:all)
            skip = true
          when '-m', '--mute'
            opts[:mute] = true
          when '-s', '--simulate'
            opts[:simulate] = true
          when '-S', '--state'
            opts[:state] = get_flag_value(arg, argv, idx)
            opts[:state] = DK::DRAFT     if opts[:state] == 'd'
            opts[:state] = DK::PUBLISH   if opts[:state] == 'p'
            opts[:state] = DK::QUEUE     if opts[:state] == 'q'
            skip = true
          when '--source'
            opts[:source] = get_flag_value(arg, argv, idx)
            opts[:source] = :draft if opts[:source] == 'd'
            opts[:source] = :queue if opts[:source] == 'q'
            skip = true
          end
        else
          command = arg
        end
      end
      [command, opts]
    end

    # Validate option flag values
    def check_opts_value(flag, val)
      if val[0] == '-'
        res  = "\nError:"
        res += "\n   Invalid value for option #{flag}: #{val}"
        res += "\n"
        res += dk_help
        raise res
      end
    end

    # Read flag's associated value
    def get_flag_value(arg, args, idx)
      invalid = check_opts_value(arg, args[idx + 1])
      unless invalid
        val = args[idx + 1]
        return true  if %w(true t).include?(val.downcase)
        return false if %w(false f).include?(val.downcase)
        return val
      end
    end

    # Display CLI Help
    def dk_help
      res  = "\n  DraftKing for tumblr (#{DK::VERSION})"
      res += "\n"
      res += "\n  Usage: "
      res += "\n     dk <COMMAND> [options]"
      res += "\n     dk -v/--version"
      res += "\n     dk -h/--help"
      res += "\n"
      res += "\n"
      res += "\n  Commands:     Required  Optional"
      res += "\n     setup                             Configure and save API keys"
      res += "\n     console                           Load irb with "
      res += "\n     blogs                             Show blog list"
      res += "\n     status                            Display number of posts in Queue, Drafts"
      res += "\n     strip                [blmsS]      Remove previous comments from Drafts"
      res += "\n     move_drafts          [bklmsS]     Move from Drafts to Queue"
      res += "\n     comment      [c]     [bklmsS]     Add comment to Posts"
      res += "\n     c_and_m      [c]     [bklms]      Add comment and move Drafts to Queue"
      res += "\n"
      res += "\n"
      res += "\n  Options: "
      res += "\n     -b, --blog      [blog_name]       Blog name to use. Excluding this will default to main blog."
      res += "\n                                         ex: 'my-blog-name' "
      res += "\n     -c, --comment   [STRING]          Comment to add."
      res += "\n                                         ex: -c 'add this comment' "
      res += "\n     -f, --filter    [STRING]          Only move posts who's comment contains the FILTER string."
      res += "\n                                         ex: -f 'only move these posts' "
      res += "\n     -k, --keep      [BOOL]            Keep previous comments when tagging. Default: FALSE"
      res += "\n     -l, --limit     [NUMBER]          Restrict number of posts selected|modified. "
      res += "\n     -m, --mute                        Suppress progress messages."
      res += "\n     -s, --simulate                    Simulation mode: Display program output without modifying actual Tumblr data."
      res += "\n     -S, --state     [d|p|q]           Set post state: d-draft, q-queued, p-published"
      res += "\n     --source        [d|q]             Modify posts from your : d-drafts, q-queue"
      res += "\n                                         (Compatible with: 'comment' or 'strip')"
      res += "\n"
      res += "\n"
      res += "\n  Examples: "
      res += "\n     dk strip -s --source q            # Simulate removing all previous comments from queued posts"
      res += "\n     dk comment -c \"q\'d\"               # Add the caption \"q\'d\" to all Drafts of main blog"
      res += "\n     dk c_and_m -l 25 -f \"q\'d\"         # Caption with \"q\'d\" and then Move the first 25"
      res += "\n"
      res += "\n  For more information :"
      res += "\n     https://github.com/meissadia/tumblr_draftking"
      res + "\n\n\n"
      # puts "   2. autopost - Autopost drafts. Defaults: 50 posts / 24 hours"
      # puts "       option 1: hours -> # of hours to run"
      # puts "       option 2: posts -> # of posts to move"
      # puts "   3. tagq - Tag Queued posts using default tag"
    end
  end
end