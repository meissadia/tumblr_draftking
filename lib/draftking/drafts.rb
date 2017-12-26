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
      post_operation(options) do |post, _|
        post.changed = true
      end
    end

    def strip_tags(options = {})
      options[:message] = 'Stripping previous comments: '
      post_operation(options) do |post, _|
        post.clear_tags
      end
    end

    # Move Drafts to Queue
    # @param options[:credit] [Bool] Give DK credit?
    # @param options[:comment] [String] HTML or Text Comment
    # @param options[:limit] [int] Limit number of posts selected
    # @param options[:key_text] [string] Modify only posts containing key_text string
    # @param options[:mute] [String] Suppress progress indicator
    # @param options[:keep_tags] [bool] Preserve existing post tags
    # @param options[:keep_tree] [bool] Preserve existing post comments
    # @param options[:simulate] [bool] Simulation?
    # @return [int] Number of modified posts
    def drafts_to_queue(options = {})
      options[:message] = 'Moving Drafts -> Queue: '
      options[:shuffle] = true
      options[:state]   = DK::QUEUE
      options[:limit] ||= options[:greedy] ? nil : @q_space
      post_operation(options) do |post, index|
        next false unless index_within_limit?(index, @q_space)
        next false unless post.has_key_text?(@key_text)
        post.replace_comment_with(@comment)
        post.change_state(@state)
        post.generate_tags(keep_tags: @keep_tags,
                           add_tags:  @tags,
                           exclude:   @comment,
                           credit:    @credit) if @auto_tag
      end
    end
  end
end
