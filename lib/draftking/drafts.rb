module DK
  # Draft methods
  module TDrafts
    # Remove comment tree
    # @param opts[:limit] [int] Limit number of posts selected
    # @param opts[:mute] [bool] Suppress progress indicator?
    # @param opts[:simulate] [bool] Simulation?
    # @return [int] Number of modified posts
    def strip_old_comments(options = {})
      options[:message] = 'Stripping previous comments: '
      post_operation(options) do |_, _, _|
        true
      end
    end

    # Move Drafts to Queue
    # @param options[:credit] [Bool] Give dk credit?
    # @param opts[:limit] [int] Limit number of posts selected
    # @param opts[:filter] [string] Modify only posts containing filter string
    # @param opts[:mute] [String] Suppress progress indicator
    # @param opts[:keep_tags] [bool] Preserve existing post tags
    # @param opts[:keep_tree] [bool] Preserve existing post comments
    # @param opts[:simulate] [bool] Simulation?
    # @return [int] Number of modified posts
    def drafts_to_queue(options = {})
      options[:message] = 'Moving Drafts -> Queue: '
      options[:shuffle] = true
      options[:state] ||= DK::QUEUE
      post_operation(options) do |post, opts, _|
        next false unless post.passes_filter?(filter: opts[:filter])
        changed = post.replace_comment(comment: opts[:comment])
        changed = post.change_state(state: opts[:state]) || changed
        changed = post.generate_tags(keep_tags: opts[:keep_tags],
                                     add_tags: opts[:add_tags],
                                     exclude: opts[:comment],
                                     credit: opts[:credit]) || changed
        changed
      end
    end
  end
end
