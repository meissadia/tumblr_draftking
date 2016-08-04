require_relative 'posts/posts_helpers'
require_relative 'posts/post'

module DK
  # Post operations common to queue/draft
  module Posts
    # Common code for Post operations
    # @param opts[:limit] [Int] Maximum number of posts to process
    # @param opts[:message] [String] Message to display during processing
    # @param opts[:shuffle] [Bool] Randomize order of posts
    # @param opts[:blog_name] [String] Name of blog to target
    # @param opts[:mute] [String] Suppress progress indicator
    # @param opts[:test_data] [[Hash]] Array of post hash data
    # @param opts[:simulate] [bool] Simulation?
    # @return [Int] # of posts modified
    def post_operation(options)
      message, opts, posts, total, modified = setup_operation(options)

      posts.each_with_index do |post, index|
        break unless index_within_limit?(modified, opts[:limit])
        po = Post.new(post, keep_tree: opts[:keep_tree])
        changed   = yield(po, opts, index) || !po.keep_tree
        modified += (changed ? po.save(client: @client, simulate: opts[:simulate] || @simulate) : 0)
        show_progress(current: index, total: total, message: message) unless options[:mute]
      end

      show_progress(message: message, done: true, modified: modified) unless options[:mute]
      act_on_blog(name: options[:blog_name] || @blog_name)
      modified
    end

    def setup_operation(options)
      msg   = options[:message]
      posts = getposts(options)
      total = options[:limit] || posts.size
      opts  = options.dup.delete_if { |k, _| k == :test_data }
      posts.shuffle! if options[:shuffle]

      [msg, opts, posts, total, 0]
    end

    # Add a comment to Posts
    # @param options[:credit] [Bool] Give dk credit?
    # @param options[:comment] [string] String to add as comment
    # @param options[:limit] [Int] Max number of modified posts
    # @param options[:message] [String] Message to display during processing
    # @param options[:source] [Symbol] Target posts from :draft or :queue
    # @param opts[:simulate] [bool] Simulation?
    # @param options[:mute] [String] Suppress progress indicator
    # @return [int] Number of modified posts
    def comment_posts(options = {})
      src = (options[:source] == :queue ? 'queue' : 'draft')
      options[:message] = "Adding #{src} comment \'#{comment}\': "
      post_operation(options) do |post, opts, _|
        changed = post.replace_comment(comment: opts[:comment])
        changed = post.generate_tags(keep_tags: opts[:keep_tags],
                                     add_tags:  opts[:add_tags],
                                     exclude:   opts[:comment],
                                     credit:    opts[:credit]) || changed if opts[:add_tags]
        changed
      end
    end

    # @param options[:credit] [Bool] Give dk credit?
    # @param options[:source] [Symbol] Target posts from :draft or :queue
    # @param options[:mute] [String] Suppress progress indicator
    # @param opts[:blog_name] [String] Name of blog to target
    # @param opts[:keep_tags] [bool] Preserve existing post tags
    # @param opts[:keep_tree] [bool] Preserve existing post comments
    # @param opts[:simulate] [bool] Simulation?
    # @param opts[:comment] [String] Exclude :comment from tags
    def tag_posts(options)
      src = (options[:source] == :queue ? 'queue' : 'draft')
      options[:message] = "Tagging #{src} with #{options[:add_tags]}: "
      post_operation(options) do |post, opts, _|
        post.generate_tags(keep_tags: opts[:keep_tags],
                           add_tags:  opts[:add_tags],
                           exclude:   opts[:comment],
                           credit:    opts[:credit])
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
    def getposts(options)
      # puts options
      # puts options.fetch(:source, :draft)
      # puts options.fetch(:source)
      return options[:test_data] if options[:test_data]
      return all_posts(blog_url: options[:blog_url], source: options.fetch(:source, :draft)).uniq unless options[:limit]
      some_posts(limit:     options[:limit],
                 offset:    options.fetch(:offset,  0),
                 before_id: options.fetch(:last_id, 0),
                 blog_url:  options[:blog_url],
                 source:    options.fetch(:source, :draft))
    end

    # Get up to 50 Drafts
    # @param blog_url [string] URL of blog to read from
    # @param source [Symbol] Get posts from :draft or :queue
    # @param before_id [Int] [:draft] ID of post to begin reading from
    # @param offset [Int] [:queue] Post index to start reading from
    # @return [[Post]] Array of Post Hash data
    def some_posts(before_id: 0, limit: 50, blog_url: nil, source: :draft, offset: 0)
      blog_url = tumblr_url(blog_url || @blog_url)
      options  = { limit: [limit, 50].min }
      options[source == :draft ? :before_id : :offset] = (source == :draft ? before_id : offset)

      result = @client.send(source, blog_url, options).first[1]
      result.is_a?(Integer) ? [] : result
    end

    # Collect all Drafts
    # @param last_id [Int] ID of post to begin reading from (for reading Drafts)
    # @param offset [Int] Post index to start reading from (for reading Queue)
    # @param blog_url [string] URL of blog to read from
    # @param source [Symbol] Get posts from :draft or :queue
    # @return [[Post]] Array of Post Hash data
    def all_posts(last_id: 0, blog_url: nil, source: :draft, offset: 0)
      chunk = some_posts(before_id: last_id, blog_url: blog_url, source: source, offset: offset)
      return chunk if chunk.empty?
      chunk + all_posts(blog_url: blog_url, last_id: chunk.last['id'], source: source, offset: offset + chunk.size)
    end
  end
end
