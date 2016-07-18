module DK
  module Helper
    # Display progress percentage
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

    def tumblr_url(s)
      s += '.tumblr.com' unless blog_url.include?('.')
      s
    end
  end
end
