module DK
  #----------------------------- Queue Methods ----------------------------- #
  module TQueue
    # Move from Queue to Drafts
    # @param options[:key_text] [String] Move posts not containing :key_text
    # @return [Int] Number of modified posts
    def move_to_drafts(options)
      options[:message] = 'Moving Queue ~> Drafts: '
      options[:shuffle] = false
      options[:state]   = DK::DRAFT
      mod_count, mod_posts = post_operation(options) do |post, _|
        post.changed = !post.has_key_text?(@key_text)
      end
      mod_count
    end
  end
end
