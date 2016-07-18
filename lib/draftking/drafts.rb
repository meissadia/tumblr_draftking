module DK
  # Draft methods
  module TDrafts
    # Remove comment tree
    # @param opts[:limit] [int] Number of posts strip. Value 0 will attempt to fill Queue
    # @param opts[:filter] [string] Move only posts whose caption contains the filter
    # @param opts[:shuffle] [bool] Randomize the order in which Drafts get added to Queue
    # @return [int] Number of modified posts
    def strip_old_comments(options = {})
      options[:message]   = 'Stripping previous comments: '
      options[:keep_tree] = false
      post_operation(options) do |post, opts|
        save_post(post, opts)
      end
    end

    # Move Drafts to Queue
    # @param opts[:limit] [int] Number of posts to move. Value 0 will attempt to fill Queue
    # @param opts[:filter] [string] Move only posts whose caption contains the filter
    # @param opts[:shuffle] [bool] Randomize the order in which Drafts get added to Queue
    # @return [int] Number of modified posts
    def drafts_to_queue(options = {})
      options[:message] = 'Moving Drafts -> Queue: '
      options[:shuffle] = true
      options[:state]   = DK::QUEUE
      post_operation(options) do |post, opts, _|
        next 0 unless post_passes_filter?(post, opts)
        changed = post_add_comment(post, opts)   || changed
        changed = post_change_state(post, opts)  || changed
        changed = post_generate_tags(post, opts) || changed
        if changed
          success = save_post(post, opts)
          next 0 unless success
          @q_size += 1
          @d_size -= 1
          success
        else
          0
        end
      end
    end
  end
end
