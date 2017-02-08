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
    def post_operation(options, &block)
      work, total, results, reporter = setup_operation(options)
      workers = (0...DK::MAX_THREADS).map { Thread.new { generate_worker(work, results, total, block) } }
      workers.map(&:join)
      mod_count, mod_posts = calculate_result(results)
      show_progress(message: message, done: true, modified: mod_count) unless @mute
      reporter.new(objects: mod_posts, title: REPORT_TITLE, fields: REPORT_FIELDS, simulate: @simulate).show unless @mute
      act_on_blog(name: @blog_name) # Refresh account info
      [mod_count, mod_posts]
    end

    # Work queue processor
    def generate_worker(*data, block)
      work, results, total = data
      begin
        while post = work.pop(true)
          po = Post.new(post, keep_tree: @keep_tree)
          block.call(po, results.size) # Do work on Post
          po.save(client: @client, simulate: @simulate)
          results.push(po)
          show_progress(current: results.size, total: total, message: message) unless @mute
        end
      rescue ThreadError # Queue empty
      end
    end

    # Common initialization for post operations
    def setup_operation(options)
      print "Setup\r" unless @mute
      process_options(options)
      act_on_blog(name: @blog_name)
      posts = @shuffle ? get_posts.reverse.shuffle : get_posts.reverse
      work = posts_to_queue(posts)
      reporter = options[:reporter] || DK::Reporter
      [work, work.size, Queue.new, reporter]
    end

    # Create queue of Posts for worker threads
    def posts_to_queue(posts)
      work_q = Queue.new
      posts.each { |p| work_q.push(p) }
      work_q
    end

    # Determine number of modified posts
    def calculate_result(result_q)
      mod_count = 0
      mod_posts = []
      return [mod_count, mod_posts] if result_q.empty?
      while post = result_q.pop
        mod_count += post.saved
        mod_posts << post if post.saved > 0
        break if result_q.empty?
      end
      [mod_count, mod_posts]
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
        post.replace_comment_with(@comment)
        post.generate_tags(keep_tags: @keep_tags,
                           add_tags:  @tags,
                           exclude:   @comment,
                           credit:    @credit) if @auto_tag
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
                           credit:    @credit) if @auto_tag
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
      print "Getting posts...\r" unless @mute
      return some_test_data if @test_data
      return some_posts(offset: @offset) if dashboard?
      return all_posts.uniq unless @limit
      return some_posts(offset: @offset, before_id: @before_id) if @limit <= 50
      limited_posts
    end

    # Get up to 50 Posts
    # @param before_id [Int] [:draft] ID of post to begin reading from
    # @param offset [Int] [:queue] Post index to start reading from
    # @return [[Post]] Array of Post Hash data
    def some_posts(before_id: 0, offset: 0, max_id: nil, since_id: nil)
      options = { limit: [(@limit || 50), 50].min }
      options[:max_id]   = max_id if max_id
      options[:since_id] = since_id if since_id
      options[@source == :draft ? :before_id : :offset] =
        (@source == :draft ? before_id : offset) unless dashboard?
      options[:type] = @type if @type

      result = call_source(options)
      result.is_a?(Integer) ? [] : result
    end

    # Dashboard integration
    def call_source(options)
      return @client.send(@source, options).first[1] if dashboard? || likes?
      @client.send(@source, @blog_url, options).first[1]
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

    # Handle limits for test data
    def some_test_data
      @limit ? @test_data.take(@limit) : @test_data
    end

    def dashboard?
      @source == :dashboard
    end

    def likes?
      @source == :likes
    end
  end
end
