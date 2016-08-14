require_relative 'posts/posts_helpers'
require_relative 'posts/post'
require 'thread'

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
      work_q, total, result_q = setup_operation(options)
      workers = (0...4).map do
        Thread.new do
          begin
            while post = work_q.pop(true)
              po = Post.new(post, keep_tree: @keep_tree)
              changed = yield(po, result_q.size) || !po.keep_tree
              result_q.push((changed ? po.save(client: @client, simulate: @simulate) : 0))
              show_progress(current: result_q.size, total: total, message: message) unless @mute
            end
          rescue ThreadError # Queue empty
          end
        end
      end
      workers.map(&:join)
      modified = calculate_result(result_q)
      show_progress(message: message, done: true, modified: modified) unless @mute
      act_on_blog(name: @blog_name) # Refresh account info
      modified
    end

    # Common initialization for post operations
    def setup_operation(options)
      process_options(options)
      act_on_blog(name: @blog_name)
      posts = @shuffle ? get_posts.shuffle : get_posts
      posts = posts.take(@limit) if @limit
      work_q = posts_to_queue(posts)
      [work_q, work_q.size, Queue.new]
    end

    # Create queue of Posts for worker threads
    def posts_to_queue(posts)
      work_q = Queue.new
      posts.each { |p| work_q.push(p) }
      work_q
    end

    # Determine number of modified posts
    def calculate_result(result_q)
      modified = 0
      modified += result_q.pop until result_q.empty?
      modified
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
      return some_posts(offset: @offset, before_id: @before_id) if @limit <= 50
      limited_posts
    end

    # Get up to 50 Posts
    # @param before_id [Int] [:draft] ID of post to begin reading from
    # @param offset [Int] [:queue] Post index to start reading from
    # @return [[Post]] Array of Post Hash data
    def some_posts(before_id: 0, offset: 0)
      options = { limit: [(@limit || 50), 50].min }
      options[@source == :draft ? :before_id : :offset] = (@source == :draft ? before_id : offset)

      result = @client.send(@source, @blog_url, options).first[1]
      result.is_a?(Integer) ? [] : result
    end

    # Get @limit # of Posts
    def limited_posts
      result = []
      until result.size >= @limit
        chunk = some_posts(offset: @offset, before_id: @before_id)
        break if chunk.empty?
        result += chunk
        @offset    = chunk.size
        @before_id = chunk.last['id']
      end
      result.take(@limit)
    end

    # Collect all Posts
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
