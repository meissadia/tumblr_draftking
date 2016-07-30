module DK
  # Helper Methods
  module Helper
    # Display progress percentage
    # @param current [Int] Progress Counter
    # @param total [Int] # Items to be processed
    # @param message [String] Display message for process
    # @param done [Bool] Processing Complete?
    # @param modified [Int] # of items modified
    def show_progress(current: 0, total: 0, message: '', done: false, modified: 0)
      if done
        indicator  = '√ '
        newline    = "\n"
        progress   = "(#{modified} modified)"
      else
        indicator  = "~#{'~' * (current.to_i % 4)}#{' ' * (3 - (current.to_i % 4))}> "
        newline    = nil
        percentage = ((current.to_f / total.to_f) * 100).round rescue 0
        progress   = "#{current} / #{total} [#{percentage}\%] "
      end
      print "#{indicator}#{message}#{progress}#{' ' * 20}\r#{newline}"
      $stdout.flush unless done
    end

    # index < limit
    def index_within_limit?(index, limit)
      return true if limit.nil? || limit == 0
      index < limit
    end

    # Construct tumblr URL string
    # @param blog_name [String] Blog Name
    def tumblr_url(blog_name)
      blog_name += '.tumblr.com' unless blog_name.include?('.')
      blog_name
    end
  end
end
