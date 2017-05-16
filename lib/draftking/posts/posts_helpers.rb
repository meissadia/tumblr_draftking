module DK
  # Helper Methods
  module Posts
    # Display progress percentage
    # @param current [Int] Progress Counter
    # @param total [Int] # Items to be processed
    # @param message [String] Display message for process
    # @param done [Bool] Processing Complete?
    # @param modified [Int] # of items modified
    def show_progress(current: 0, total: 0, message: '', done: false, modified: 0)
      indicator, newline, progress = setup_done(modified) if done
      indicator, newline, progress = setup_undone(current, total) unless done
      print "#{indicator}#{message}#{progress}#{' ' * 30}\r#{newline}"
      $stdout.flush unless done
    end

    # Values for displaying completed process
    def setup_done(modified)
      indicator  = '√ '
      newline    = "\n"
      progress   = "(#{modified} modified)"
      [indicator, newline, progress]
    end

    # Values for displaying in-progress process
    def setup_undone(current, total)
      tildes = current.to_i % 4
      indicator  = "~#{'~' * tildes}#{' ' * (3 - tildes)}> "
      newline    = nil
      percentage = total > 0 ? ((current.to_f / total.to_f) * 100).round : 0
      progress   = "#{current} / #{total} [#{percentage}\%] "
      [indicator, newline, progress]
    end

    # Construct Tumblr URL string
    # @param blog_name [String] Blog Name
    def tumblr_url(blog_name)
      return '' unless blog_name
      blog_name += '.tumblr.com' unless blog_name.include?('.')
      blog_name
    end

    # Convert source symbol to string
    # @param symbol [Symbol] Source Symbol
    def source_string(symbol)
      return 'draft' unless symbol
      symbol.to_s
    end

    # index < limit
    def index_within_limit?(index, limit)
      return true if limit.nil? || limit.zero?
      index < limit
    end
  end
end
