module DK
  #----------------------------- Queue Methods ----------------------------- #
  module TQueue
    # Number of posts in Queue
    # @param recalculate [bool] Force recalculation of size
    # @return [int] size of queue
    def queue_size
      @q_size
    end

    # Number of posts that can be added to Queue
    # @param recalculate [bool] Force recalculation of size
    # @return [int] queue spaces available
    def queue_space
      301 - queue_size
    end

    # Move improperly tagged Queue to Drafts
    # @param options[:tag] [bool] Any posts whose caption does not begin with :tag are moved to Drafts
    # @return modified [int] Number of modified posts
    def move_to_drafts(options)
      options[:message] = 'Moving Queue ~> Drafts: '
      options[:shuffle] = false
      options[:state]   = DK::DRAFT
      post_operation(options) do |post, opts, _|
        po = Post.new(post)
        next 0 if po.passes_filter?(filter: opts[:filter])
        po.save(client: @client, simulate: @simulate)
      end
    end

    # # Get a list of Queued posts
    # # @param offset [int] return queued posts starting with offset index
    # # @return [[Post]] Array of Post JSON objects
    # def some_queue(offset = 0, limit = 1)
    #   queue = @client.queue @blog_url, offset: offset, limit: limit
    #   queue.first[1]
    # end
    #
    # # Collect entire Queue
    # # @note reads in chunks of 20 posts, so runtime can be slow.
    # # @return [[Post]] Array of Post JSON objects
    # def all_queue
    #   queue = []
    #   offset = 0
    #   loop do
    #     q_t = @client.queue(@blog_url, offset: offset, limit: 50).first[1]
    #     break if q_t.empty?
    #     offset += q_t.size
    #     queue += q_t
    #   end
    #   queue
    # end

    # # Add a comment to Queue
    # # @param caption [string] String to add as caption
    # # @param options[:all] [bool] Process entire Queue
    # # @param options[:skip] [String] Do not modify Queued posts that contain string
    # # @return [int] Number of posts modified
    # def comment_queue(caption, options)
    #   queue = options[:all] ? all_queue : some_queue(0, 50)
    #   skip = options[:skip]
    #   modified = 0
    #   if skip.nil?
    #     queue.each do |d|
    #       @client.edit @blog_url, id: d['id'], reblog_key: d['reblog_key'], caption: caption, state: 'queue'
    #       modified += 1
    #     end
    #   else
    #     queue.each do |d|
    #       next if d['summary'].include?(skip)
    #       @client.edit @blog_url, id: d['id'], reblog_key: d['reblog_key'], caption: caption, state: 'queue'
    #       modified += 1
    #     end
    #   end
    #   modified
    # end

    # # Tag Queued posts from comment
    # # @return [int] Number of posts modified
    # def tag_queue
    #   puts 'Tagging Queue'
    #   queue = all_queue
    #   mod = 0
    #   queue.each do |d|
    #     caption = d['summary']
    #     next unless caption.include?('/')
    #     tags = caption.gsub(%r{[\/\\|]}, ',').gsub(' , ', ',') # Tag with caption
    #     puts "#{caption} => #{tags}"
    #     @client.edit @blog_url, id: d['id'], reblog_key: d['reblog_key'], caption: caption, tags: tags, state: 'draft'
    #     @client.edit @blog_url, id: d['id'], reblog_key: d['reblog_key'], caption: caption, tags: tags, state: 'queue'
    #     mod += 1
    #   end
    #   puts 'Done'
    #   puts "Tags added to #{mod} queue posts"
    #   mod
    # end

    # def auto_post(hours = 24, post_count = 50)
    #   puts "Auto-posting #{post_count} posts over #{hours} hours:"
    #   seconds = hours * 60 * 60
    #   sleep_time = seconds / post_count
    #   delay_in_mins = sleep_time / 60
    #   offset = 0
    #   limit = 1
    #   posts_left = post_count
    #   post_count.times do
    #     if posts_available && posts_left > 0
    #       publish_post(some_queue(offset, limit).first)
    #       posts_left -= 1
    #       if posts_available && posts_left > 0
    #         puts "Next post at #{Time.now + (delay_in_mins * 60)} mins"
    #         sleep sleep_time
    #       end
    #     else
    #       puts 'Processing complete!'
    #       break
    #     end
    #   end
    # end
    #
    # def publish_post(d)
    #   print "Posting: #{d['summary']} .."
    #   @client.edit @blog_url, id: d['id'], reblog_key: d['reblog_key'], caption: d['summary'], tags: d['tags'], state: 'published'
    #   @q_size -= 1
    #   puts '.Done'
    # end
  end
end
