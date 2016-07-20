module DK
  module Posts
    # Common code for Post operations
    def post_operation(options)
      post_a   = getposts(options)
      message  = options[:message]
      mod_opts = options.dup.delete_if { |k, _| k == :test_data }
      modified = 0
      total    = options[:limit] || post_a.size

      post_a.shuffle! if options[:shuffle]

      post_a.each_with_index do |post, index|
        break unless index_within_limit?(modified, mod_opts[:limit])
        modified += yield(post, mod_opts, index)
        show_progress(current: index, total: total, message: message) unless options[:mute]
      end
      show_progress(message: message, done: true, modified: modified) unless options[:mute]
      modified
    end

    # Determine draft data to use. Precedence: options[:test_data] -> options[:limit] -> Default = All Drafts
    # @param options[:test_data] [[Hash]] Array of post hash data
    # @param options[:limit] [Int] Max number of posts
    # @return [[Hash]] Post Data
    def getposts(options)
      posts   = options[:test_data]
      posts ||= options[:limit] ?
                some_posts(limit:     options[:limit],
                           offset:    options.fetch(:offset,  0),
                           before_id: options.fetch(:last_id, 0),
                           blog_url:  options[:blog_url],
                           source:    options.fetch(:source, :draft)) :
                all_posts(blog_url: options[:blog_url],
                          source:   options.fetch(:source, :draft)).uniq
    end

    # Get up to 50 Drafts
    # @param options[:blog_url] [string] URL of blog to read from
    # @param options[:source] [Symbol] Get posts from :draft or :queue
    # @param options[:before_id] [Int] [:draft] ID of post to begin reading from
    # @param options[:offset] [Int] [:queue] Post index to start reading from
    # @return [[Post]] Array of Post Hash data
    def some_posts(before_id: 0, limit: 50, blog_url: nil, source: :draft, offset: 0)
      blog_url ||= @blog_url
      blog_url   = tumblr_url(blog_url)

      options = { limit: [limit, 50].min }
      options[source == :draft ? :before_id : :offset] = (source == :draft ? before_id : offset)

      result = @client.send(source, blog_url, options).first[1]
      return result unless result.is_a?(Integer)
      []
    end

    # Collect all Drafts
    # @param options[:blog] [string] URL of blog to read from
    # @param options[:source] [Symbol] Get posts from :draft or :queue
    # @param options[:offset] [Int] [:queue] Post index to start reading from
    # @param options[:last_id] [Int] [:draft] ID of post to begin reading from
    # @return [[Post]] Array of Post Hash data
    def all_posts(last_id: 0, blog_url: nil, source: :draft, offset: 0)
      chunk = some_posts(before_id: last_id, blog_url: blog_url, source: source, offset: offset)
      return chunk if chunk.empty?
      chunk + all_posts(blog_url: blog_url, last_id: chunk.last['id'], source: source, offset: offset + chunk.size)
    end

    # Add a comment to Posts
    # @param options[:caption] [string] String to add as comment
    # @param options[:limit] [Int] Max number of modified posts
    # @return [int] Number of modified posts
    def comment_posts(options = {})
      src = options[:source] == :queue ? 'queue' : 'draft'
      comment = options.fetch(:comment, comment)
      options[:message] = "Adding #{src} comment \'#{comment}\': "
      post_operation(options) do |post, opts, _|
        changed = post_add_comment(post, opts) || changed
        changed ? save_post(post, opts) : 0
      end
    end

    # Save a post
    def save_post(d, options = {})
      return 1 if @simulate
      res = @client.edit tumblr_url(options.fetch(:blog_url, @blog_url)),
                         id:                 d['id'],
                         reblog_key:         d['reblog_key'],
                         state:              options.fetch(:state,     DK::DRAFT),
                         attach_reblog_tree: options.fetch(:keep_tree, true),
                         tags:               options.fetch(:tags,      d['tags']),
                         caption:            d['caption'].empty? ? options.fetch(:comment, comment) || d['caption'] : d['caption']
      res['id'] ? 1 : 0
    end

    # Save an array of posts
    def save_posts(posts, options = {})
      posts.each { |p| save_post(p, options) }
    end

    # Add a comment to a post
    def post_add_comment(post, opts = {})
      caption = opts.fetch(:comment, @comment)
      return false if caption.nil? || post['caption'].include?(caption)
      post['caption'] = caption
      true
    end

    # Change the state of a post
    def post_change_state(post, opts = {})
      state = opts[:state]
      return false unless VALID_STATE.include?(state)
      post['state'] = state
      true
    end

    # Check if a post needs to be modified
    def post_passes_filter?(post, options = {})
      filter = options[:filter]
      return true if filter.nil?
      post['summary'].include?(filter)
    end

    # Generate post tags from post comment
    def post_generate_tags(post, opts = {})
      filter  = opts.fetch(:filter,  '')
      comment = opts.fetch(:comment, '')
      tags  = post['reblog']['comment'].gsub(%r{<[/]*p>}, '')
      tags  = tags.gsub(%r{[\/\\|]}, ',').gsub(' , ', ',').gsub(filter, '').gsub(comment, '') # Generate tags from caption
      tags += opts.fetch(:tags, '')
      tags += post['tags'] if opts[:keep_tags]
      unless post['tags'] == tags
        post['tags'] = tags
        return true
      end
      false
    end

    # def posts_available?
    #   @q_size > 0
    # end
  end
end
