module DK
  #----------------------------- Queue Methods ----------------------------- #
  module TQueue
    # Move from Queue to Drafts
    # @param options[:filter] [String] Modify posts not containing :filter
    # @return [Int] Number of modified posts
    def move_to_drafts(options)
      options[:message] = 'Moving Queue ~> Drafts: '
      options[:shuffle] = false
      options[:state]   = DK::DRAFT
      post_operation(options) do |post, opts, _|
        !post.passes_filter?(filter: opts[:filter])
      end
    end
  end
end
