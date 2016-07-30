module DK
  # Draft methods
  module TDrafts
    # Remove comment tree
    # @param opts[:limit] [int] Number of posts strip. Value 0 will attempt to fill Queue
    # @param opts[:filter] [string] Move only posts whose caption contains the filter
    # @param opts[:mute] [String] Suppress progress indicator
    # @param opts[:shuffle] [bool] Randomize the order in which Drafts get added to Queue
    # @return [int] Number of modified posts
    def strip_old_comments(options = {})
      options[:message] = 'Stripping previous comments: '
      post_operation(options) do |post, opts, _|
        po = Post.new(post, keep_tree: false)
        po.save(client: @client, simulate: opts[:simulate] || @simulate)
      end
    end

    # Move Drafts to Queue
    # @param opts[:limit] [int] Number of posts to move. Value 0 will attempt to fill Queue
    # @param opts[:filter] [string] Move only posts whose caption contains the filter
    # @param opts[:shuffle] [bool] Randomize the order in which Drafts get added to Queue
    # @param opts[:mute] [String] Suppress progress indicator
    # @return [int] Number of modified posts
    def drafts_to_queue(options = {})
      options[:message] = 'Moving Drafts -> Queue: '
      options[:shuffle] = true
      options[:state] ||= DK::QUEUE
      post_operation(options) do |post, opts, _|
        po = Post.new(post, keep_tree: opts[:keep_tree])
        next 0 unless po.passes_filter?(filter: opts[:filter])
        changed = po.replace_comment(comment: opts[:comment])
        changed ||= po.change_state(state: opts[:state])
        changed ||= po.generate_tags(keep_tags: opts[:keep_tags], add_tags: opts[:add_tags], exclude: opts[:comment])
        return 0 unless changed
        po.save(client: @client, simulate: opts[:simulate] || @simulate)
      end
    end
  end
end
