module DK
  # Draft methods
  module TDrafts
    # Remove comment tree
    # @param options[:limit] [int] Limit number of posts selected
    # @param options[:mute] [bool] Suppress progress indicator?
    # @param options[:simulate] [bool] Simulation?
    # @return [int] Number of modified posts
    def strip_old_comments(options = {})
      options[:message] = 'Stripping previous comments: '
      post_operation(options) do |_, _|
        true
      end
    end

    # Move Drafts to Queue
    # @param options[:credit] [Bool] Give DK credit?
    # @param options[:limit] [int] Limit number of posts selected
    # @param options[:filter] [string] Modify only posts containing filter string
    # @param options[:mute] [String] Suppress progress indicator
    # @param options[:keep_tags] [bool] Preserve existing post tags
    # @param options[:keep_tree] [bool] Preserve existing post comments
    # @param options[:simulate] [bool] Simulation?
    # @return [int] Number of modified posts
    def drafts_to_queue(options = {})
      options[:message] = 'Moving Drafts -> Queue: '
      options[:shuffle] = true
      options[:state]   = DK::QUEUE
      post_operation(options) do |post, index|
        next false unless index_within_limit?(index, @q_space)
        next false unless post.passes_filter?(filter: @filter)
        changed = post.replace_comment(comment: @comment)
        changed = post.change_state(state: @state) || changed
        changed = post.generate_tags(keep_tags: @keep_tags,
                                     add_tags:  @tags,
                                     exclude:   @comment,
                                     credit:    @credit) || changed
        changed
      end
    end
  end
end
