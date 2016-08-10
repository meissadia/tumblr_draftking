require_relative 'posts/posts_helpers'
require_relative 'posts/post'

module DK
  # Post operations common to queue/draft
  module Posts
    # Common code for Post operations
    # @param options[:limit] [Int] Maximum number of posts to process
    # @param options[:message] [String] Message to display during processing
    # @param options[:shuffle] [Bool] Randomize order of posts
    # @param options[:blog_name] [String] Name of blog to target
    # @param options[:mute] [String] Suppress progress indicator
    # @param options[:test_data] [[Hash]] Array of post hash data
    # @param options[:simulate] [bool] Simulation?
    # @return [int] Number of modified posts
    def post_operation(options)
      posts, total, modified = setup_operation(options)

      posts.each_with_index do |post, index|
        po = Post.new(post, keep_tree: @keep_tree)
        changed   = yield(po, index) || !po.keep_tree
        modified += (changed ? po.save(client: @client, simulate: @simulate) : 0)
        show_progress(current: index, total: total, message: message) unless @mute
      end

      show_progress(message: message, done: true, modified: modified) unless @mute
      act_on_blog(name: @blog_name) # Refresh account info
      modified
    end

    def setup_operation(options)
      process_options(options)
      act_on_blog(name: @blog_name)
      posts = @shuffle ? get_posts.shuffle : get_posts
      posts = posts.take(@limit || @q_space)
      [posts, posts.size, 0]
    end

    # Add a comment to Posts
    # @param options[:credit] [Bool] Give dk credit?
    # @param options[:comment] [string] String to add as comment
    # @param options[:limit] [Int] Max number of modified posts
    # @param options[:message] [String] Message to display during processing
    # @param options[:source] [Symbol] Target posts from :draft or :queue
    # @param options[:simulate] [bool] Simulation?
    # @param options[:mute] [String] Suppress progress indicator
    # @return [int] Number of modified posts
    def comment_posts(options = {})
      src = source_string(options[:source])
      options[:message] = "Adding #{src} comment \'#{comment}\': "
      post_operation(options) do |post, _|
        changed = post.replace_comment(comment: @comment)
        changed = post.generate_tags(keep_tags: @keep_tags,
                                     add_tags:  @tags,
                                     exclude:   @comment,
                                     credit:    @credit) || changed if @tags
        changed
      end
    end

    # @param options[:credit] [Bool] Give dk credit?
    # @param options[:source] [Symbol] Target posts from :draft or :queue
    # @param options[:mute] [String] Suppress progress indicator
    # @param options[:blog_name] [String] Name of blog to target
    # @param options[:keep_tags] [bool] Preserve existing post tags
    # @param options[:keep_tree] [bool] Preserve existing post comments
    # @param options[:simulate] [bool] Simulation?
    # @param options[:comment] [String] Exclude :comment from tags
    # @return [int] Number of modified posts
    def tag_posts(options)
      src = source_string(options[:source])
      options[:message] = "Tagging #{src} with #{options[:add_tags]}: "
      post_operation(options) do |post, _|
        post.generate_tags(keep_tags: @keep_tags,
                           add_tags:  @tags,
                           exclude:   @comment,
                           credit:    @credit)
      end
    end

    # Determine draft data to use.
    # @param options[:test_data] [[Hash]] Array of post hash data
    # @param options[:limit] [Int] Limit # of posts selected
    # @param options[:blog_url] [string] URL of blog to read from
    # @param options[:source] [Symbol] Get posts from :draft or :queue
    # @param options[:before_id] [Int] [:draft] ID of post to begin reading from
    # @param options[:offset] [Int] [:queue] Post index to start reading from
    # @return [[Post]] Array of Post Hash data
    def get_posts
      return @test_data if @test_data
      return all_posts.uniq unless @limit
      some_posts(offset: @offset, before_id: @before_id)
    end

    # Get up to 50 Drafts
    # @param blog_url [string] URL of blog to read from
    # @param source [Symbol] Get posts from :draft or :queue
    # @param before_id [Int] [:draft] ID of post to begin reading from
    # @param offset [Int] [:queue] Post index to start reading from
    # @return [[Post]] Array of Post Hash data
    def some_posts(before_id: 0, offset: 0)
      options = { limit: [(@limit || 50), 50].min }
      options[@source == :draft ? :before_id : :offset] = (@source == :draft ? before_id : offset)

      result = @client.send(@source, @blog_url, options).first[1]
      result.is_a?(Integer) ? [] : result
    end

    # Collect all Drafts
    # @param last_id [Int] ID of post to begin reading from (for reading Drafts)
    # @param offset [Int] Post index to start reading from (for reading Queue)
    # @param blog_url [string] URL of blog to read from
    # @param source [Symbol] Get posts from :draft or :queue
    # @return [[Post]] Array of Post Hash data
    def all_posts(last_id: 0, offset: 0)
      chunk = some_posts(before_id: last_id, offset: offset)
      return chunk if chunk.empty?
      chunk + all_posts(last_id: chunk.last['id'], offset: offset + chunk.size)
    end
  end
end
